USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [IP].[DATA_SELECT]
	@SYS	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@UNCOMPLETE	BIT = 0
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

		SELECT
			CSD_DATE, CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME, CSD_LOG_PATH, CSD_LOG_FULL, CSD_USR,
			CLIENT_CODE, CLIENT_CODE_ERROR, SERVER_CODE, SERVER_CODE_ERROR, STT_SEND
		FROM
			IP.ClientStatDetailView c
		WHERE CSD_SYS = @SYS AND CSD_DISTR = @DISTR AND CSD_COMP = @COMP
			AND CSD_DATE >= DATEADD(MONTH, -3, GETDATE())

		UNION ALL

		SELECT
			LF_DATE, NULL, NULL, FL_NAME, '', NULL,
			NULL, NULL, NULL, NULL, NULL
		FROM
			IP.LogFileView a
		WHERE LF_DATE >= DATEADD(HOUR, -168, GETDATE())
			AND @UNCOMPLETE = 1
			AND a.LF_DISTR = @DISTR
			AND a.LF_COMP = @COMP
			AND a.LF_SYS = @SYS
			AND NOT EXISTS
				(
					SELECT *
					FROM IP.ClientStatView
					WHERE CSD_DISTR = LF_DISTR
						AND CSD_COMP = LF_COMP
						AND CSD_SYS = LF_SYS
						AND DATEADD(MILLISECOND, -DATEPART(MILLISECOND, CSD_DATE), CSD_DATE) = LF_DATE
				)

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
GRANT EXECUTE ON [IP].[DATA_SELECT] TO rl_client_ip;
GO