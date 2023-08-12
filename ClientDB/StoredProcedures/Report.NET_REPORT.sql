USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[NET_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[NET_REPORT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Report].[NET_REPORT]
	@PARAM NVARCHAR(MAX) = NULL
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

		DECLARE @HST_ID	INT

		SELECT @HST_ID = HostID
		FROM dbo.Hosts
		WHERE HostReg = 'LAW'

		DECLARE @TOTAL INT

		SELECT @TOTAL = COUNT(*)
		FROM Reg.RegNodeSearchView WITH(NOEXPAND)
		WHERE HostID = @HST_ID
			AND DS_REG = 0
			AND SST_SHORT NOT IN ('ОДД', 'ДСП', 'АДМ', 'ДИУ')

		IF OBJECT_ID('tempdb..#net') IS NOT NULL
			DROP TABLE #net

		CREATE TABLE #net
			(
				NT_ID		INT,
				NT_SHORT	NVARCHAR(128),
				CNT			INT,
				NT_TECH		INT,
				NT_NET		INT
			)

		INSERT INTO #net(NT_ID, NT_SHORT, CNT, NT_TECH, NT_NET)
			SELECT
				NT_ID, NT_SHORT,
				(
					SELECT COUNT(*)
					FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
					WHERE HostID = @HST_ID
						AND DS_REG = 0
						AND z.NT_ID = a.NT_ID
						AND SST_SHORT NOT IN ('ОДД', 'ДСП', 'АДМ', 'ДИУ')
				),
				NT_TECH, NT_NET
			FROM Din.NetType a


		SELECT NT_SHORT AS [Название], CNT AS [Кол-во], PRC AS [% от общего]
		FROM
			(
				SELECT 1 AS TP, NT_SHORT, NT_TECH, NT_NET, CNT, ROUND(CONVERT(FLOAT, CNT) / @TOTAL * 100, 2) AS PRC
				FROM #net

				UNION ALL

				SELECT 2 AS TP, 'Всего онлайн-версий', NULL, NULL, (SELECT SUM(CNT) FROM #net WHERE NT_TECH > 2), ROUND(CONVERT(FLOAT, (SELECT SUM(CNT) FROM #net WHERE NT_TECH > 2)) / @TOTAL * 100, 2)
			) AS o_O
		ORDER BY TP, NT_TECH, NT_NET

		--SELECT ROUND(CONVERT(FLOAT, (SELECT SUM(CNT) FROM #net WHERE NT_TECH > 2)) / @TOTAL * 100, 2)

		IF OBJECT_ID('tempdb..#net') IS NOT NULL
			DROP TABLE #net

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[NET_REPORT] TO rl_report;
GO
