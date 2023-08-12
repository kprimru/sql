USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[IP_JOURNAL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[IP_JOURNAL_SELECT]  AS SELECT 1')
GO

CREATE OR ALTER PROCEDURE [Subhost].[IP_JOURNAL_SELECT]
	@SUBHOST	NVARCHAR(16),
	@DISTR		INT,
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@UNCOMPLETE	BIT,
	@CLIENT		NVARCHAR(256) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Distrs TABLE
	(
		HostId			SmallInt,
		SystemNumber	Int,
		Distr			Int,
		Comp			TinyInt,
		PRIMARY KEY CLUSTERED(Distr, HostId, Comp, SystemNumber)
	);

	DECLARE @Result Table
	(
		TP					TinyInt,
		DS_INDEX			TinyInt,
		Comment				VarChar(255),
		DistrStr			VarChar(100),
		CSD_DATE			DateTime,
		CSD_DOWNLOAD_TIME	VarChar(100),
		CSD_UPDATE_TIME		VarChar(100),
		CSD_LOG_FULL		VarChar(1024),
		CSD_USR				VarChar(256),
		CSD_USR_FULL		VarChar(1024),
		CLIENT_CODE			VarChar(256),
		SERVER_CODE			VarChar(256),
		STT_SEND			VarChar(128),
		CLIENT_CODE_ERROR	Bit,
		SERVER_CODE_ERROR	Bit
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @FINISH = DATEADD(DAY, 1, @FINISH)
		IF @CLIENT = ''
			SET @CLIENT = NULL
		ELSE
			SET @CLIENT = '%' + @CLIENT + '%'

		INSERT INTO @Distrs
		SELECT D.HostId, S.SystemNumber, D.DistrNumber, D.CompNumber
		FROM dbo.SubhostDistrs@Get(NULL, @SUBHOST)	AS D
		INNER JOIN dbo.SystemTable					AS S ON D.HostId = S.HostId
		WHERE S.SystemRic = 20
			AND (D.DistrNumber = @DISTR OR @DISTR IS NULL);

		INSERT INTO @Result
		SELECT
			0 AS TP, DS_INDEX,
			R.Comment, R.DistrStr,
			CSD_DATE, CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME, CSD_LOG_FULL, CSD_USR, CSD_USR_FULL,
			CLIENT_CODE, SERVER_CODE, STT_SEND, CLIENT_CODE_ERROR, SERVER_CODE_ERROR
		FROM @Distrs						AS D
		INNER JOIN Reg.RegNodeSearchView	AS R WITH(NOEXPAND) ON R.HostID = D.HostID
																AND R.DistrNumber = D.Distr
																AND R.CompNumber = D.Comp
		INNER JOIN IP.ClientStatDetailView	AS I ON I.CSD_DISTR = D.Distr
												AND I.CSD_COMP = D.Comp
												AND I.CSD_SYS = D.SystemNumber
		WHERE (R.Comment LIKE @CLIENT OR @CLIENT IS NULL)
			AND (I.CSD_DATE >= @START OR @START IS NULL)
			AND (I.CSD_DATE < @FINISH OR @FINISH IS NULL)
		OPTION(RECOMPILE);


		IF @UNCOMPLETE = 1
			INSERT INTO @Result(TP, DS_INDEX, Comment, DistrStr, CSD_DATE, CSD_LOG_FULL)
			SELECT
				1 AS TP, DS_INDEX,
				R.Comment, R.DistrStr, LF_DATE, FL_NAME
			FROM  @Distrs						AS D
			INNER JOIN Reg.RegNodeSearchView	AS R WITH(NOEXPAND) ON R.HostID = D.HostID
																AND R.DistrNumber = D.Distr
																AND R.CompNumber = D.Comp
			INNER JOIN IP.LogFileView			AS I ON I.LF_DISTR = D.Distr
												AND I.LF_COMP = D.Comp
												AND I.LF_SYS = D.SystemNumber
			WHERE LF_DATE >= DATEADD(HOUR, -12, GETDATE())
				AND (R.Comment LIKE @CLIENT OR @CLIENT IS NULL)
				AND (I.LF_DATE >= @START OR @START IS NULL)
				AND (I.LF_DATE < @FINISH OR @FINISH IS NULL)
					--AND (a.LF_DATE >= DATEADD(MONTH, -3, GETDATE()))
				AND NOT EXISTS
					(
						SELECT *
						FROM IP.ClientStatView
						WHERE CSD_DISTR = LF_DISTR
							AND CSD_COMP = LF_COMP
							AND CSD_SYS = LF_SYS
							AND CSD_START_WITHOUT_MS = LF_DATE
					)
			OPTION(RECOMPILE);

		SELECT *
		FROM @Result
		ORDER BY CSD_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[IP_JOURNAL_SELECT] TO rl_web_subhost;
GO
