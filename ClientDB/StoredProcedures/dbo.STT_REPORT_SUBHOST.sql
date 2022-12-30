USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STT_REPORT_SUBHOST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STT_REPORT_SUBHOST]  AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[STT_REPORT_SUBHOST]
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@UNCOLLECT	BIT,
	@SH			NVARCHAR(64) = NULL OUTPUT,
	@SH_NAME	NVARCHAR(64) = NULL OUTPUT,
	@PERCENT	FLOAT = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		SET @SH = Maintenance.GlobalSubhostName()

		--Получаем полное название подхоста
		SET @SH_NAME = (SELECT [SH_NAME] FROM [ClientDB].[dbo].[Subhost] WHERE [SH_REG] = @SH)

		SET @FINISH = DATEADD(DAY, 1, @FINISH)

		DECLARE @HOST	INT

		SELECT @HOST = HostID
		FROM dbo.Hosts
		WHERE HostReg = 'LAW'

		DECLARE @SYSTEM	INT

		SELECT @SYSTEM = SystemID
		FROM dbo.SystemTable
		WHERE SystemBaseName = 'RGN'

		IF OBJECT_ID('tempdb..#ip') IS NOT NULL
			DROP TABLE #ip

		CREATE TABLE #ip
			(
				SYS		SMALLINT,
				DISTR	INT,
				COMP	TINYINT
			)

		INSERT INTO #ip(SYS, DISTR, COMP)
			SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
			FROM dbo.IPSTTView
			WHERE CSD_START >= @START AND CSD_START < @FINISH

		IF OBJECT_ID('tempdb..#stt') IS NOT NULL
			DROP TABLE #stt

		CREATE TABLE #stt
			(
				Comment		NVARCHAR(128),
				DistrStr	NVARCHAR(128),
				SST_SHORT	NVARCHAR(128),
				NT_SHORT	NVARCHAR(128),
				STT_COUNT	INT,
				SystemOrder	INT,
				DistrNumber	INT,
				CompNumber	TINYINT
			)

		INSERT INTO #stt(Comment, DistrStr, SST_SHORT, NT_SHORT, STT_COUNT, SystemOrder, DistrNumber, CompNumber)
			SELECT
				Comment, DistrStr, SST_SHORT, NT_SHORT,
				CASE
					WHEN STT_COUNT = 0 AND IP_DISTR IS NOT NULL THEN -1
					ELSE STT_COUNT
				END AS STT_COUNT, SystemOrder, DistrNumber, CompNumber
			FROM
				(
					SELECT
						b.Comment, b.DistrStr, b.SST_SHORT, b.NT_SHORT,
						(
							SELECT COUNT(DISTINCT OTHER)
							FROM
								dbo.ClientStat z
								INNER JOIN dbo.SystemTable y ON SYS_NUM = SystemNumber
							WHERE b.HostID = y.HostID AND z.DISTR = DistrNumber AND z.COMP = CompNumber
								AND DATE >= @START
								AND DATE < @FINISH
						) AS STT_COUNT,
						c.DISTR AS IP_DISTR,
						b.DistrNumber, b.HostID, b.CompNumber, b.SystemOrder
					FROM
						(
							SELECT SC_ID_HOST, SC_DISTR, SC_COMP
							FROM
								dbo.SubhostComplect a
								INNER JOIN dbo.Subhost b ON a.SC_ID_SUBHOST = b.SH_ID
							WHERE SH_REG = @SH
								AND SC_ACTIVE = 1

							UNION

							SELECT HostID, DistrNumber, CompNumber
							FROM Reg.RegNodeSearchView WITH(NOEXPAND)
							WHERE SubhostName = @SH
						) AS a
						INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.SC_ID_HOST = b.HostID AND a.SC_DISTR = b.DistrNumber AND a.SC_COMP = b.CompNumber
						INNER JOIN dbo.SystemTable d ON b.SystemID = d.SystemID
						LEFT OUTER JOIN #ip c ON c.SYS = d.SystemNumber AND c.DISTR = b.DistrNumber AND c.COMP = b.CompNumber
					WHERE DS_REG = 0
						AND (b.HostID = @HOST OR b.SystemID = @SYSTEM)
						AND SST_SHORT NOT IN ('ОДД', /*'ДИУ', */'АДМ', 'ДСП')
						AND NT_SHORT NOT IN ('онлайн', 'онлайн2', 'онлайн3', 'мобильная', 'ОВМ (ОД 1)', 'ОВМ (ОД 2)', 'ОВП', 'ОВПИ', 'ОВК', 'ОВМ1', 'ОВМ2', 'ОВК-Ф')
						AND b.Complect LIKE b.SystemBaseName + '%'
				) AS o_O

		SELECT Comment, DistrStr, SST_SHORT, NT_SHORT, STT_COUNT
		FROM #stt
		WHERE (@UNCOLLECT = 0 OR @UNCOLLECT = 1 AND STT_COUNT = 0)
		ORDER BY SystemOrder, DistrNumber, CompNumber

		SET @PERCENT = 100 * CONVERT(FLOAT, (SELECT COUNT(*) FROM #stt WHERE STT_COUNT <> 0)) / (SELECT COUNT(*) FROM #stt)

		SET @PERCENT = ROUND(@PERCENT, 2)

		IF OBJECT_ID('tempdb..#stt') IS NOT NULL
			DROP TABLE #stt

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STT_REPORT_SUBHOST] TO rl_stt_report_subhost;
GO
