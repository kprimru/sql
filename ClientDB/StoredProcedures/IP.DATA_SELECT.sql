USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[IP].[DATA_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [IP].[DATA_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [IP].[DATA_SELECT]
	@System		Int,
	@Distr		Int,
	@Comp		TinyInt,
	@Uncomplete	Bit	= 0
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@MinStatDate	Date = DateAdd(Month, -3, GetDate()),
		@MinLogDate		Date = DateAdd(Day, -7, GetDate());

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			[CSD_DATE]				= D.[CSD_DATE],
			[CSD_DOWNLOAD_TIME]		= D.[CSD_DOWNLOAD_TIME],
			[CSD_UPDATE_TIME]		= D.[CSD_UPDATE_TIME],
			[CSD_LOG_PATH]			= D.[CSD_LOG_PATH],
			[CSD_LOG_FULL]			= D.[CSD_LOG_FULL],
			[CSD_USR]				= D.[CSD_USR],
			[CLIENT_CODE]			= D.[CLIENT_CODE],
			[CLIENT_CODE_ERROR]		= D.[CLIENT_CODE_ERROR],
			[SERVER_CODE]			= D.[SERVER_CODE],
			[SERVER_CODE_ERROR]		= D.[SERVER_CODE_ERROR],
			[STT_SEND]				= D.[STT_SEND],
			[SRV_ID]				= D.[FL_ID_SERVER],
			[SRV_NAME]				= D.[SRV_NAME]
		FROM [IP].[ClientStatDetailView] AS D
		WHERE	D.[CSD_SYS] = @System
			AND D.[CSD_DISTR] = @Distr
			AND D.[CSD_COMP] = @Comp
			AND D.[CSD_DATE] >= @MinStatDate

		UNION ALL

		SELECT
			[CSD_DATE]				= L.[LF_DATE],
			[CSD_DOWNLOAD_TIME]		= NULL,
			[CSD_UPDATE_TIME]		= NULL,
			[CSD_LOG_PATH]			= L.[FL_NAME],
			[CSD_LOG_FULL]			= '',
			[CSD_USR]				= NULL,
			[CLIENT_CODE]			= NULL,
			[CLIENT_CODE_ERROR]		= NULL,
			[SERVER_CODE]			= NULL,
			[SERVER_CODE_ERROR]		= NULL,
			[STT_SEND]				= NULL,
			[SRV_ID]				= L.[FL_ID_SERVER],
			[SRV_NAME]				= L.[SRV_NAME]
		FROM [IP].[LogFileView] AS L
		WHERE L.[LF_DATE] >= @MinLogDate
			AND @Uncomplete = 1
			AND L.[LF_DISTR] = @Distr
			AND L.[LF_COMP] = @Comp
			AND L.[LF_SYS] = @System
			AND NOT EXISTS
				(
					SELECT *
					FROM [IP].[ClientStatView] AS S
					WHERE S.[CSD_DISTR] = L.[LF_DISTR]
						AND S.[CSD_COMP] = L.[LF_COMP]
						AND S.[CSD_SYS] = L.[LF_SYS]
						--AND DATEADD(MILLISECOND, -DATEPART(MILLISECOND, CSD_DATE), CSD_DATE) = LF_DATE
						AND S.[CSD_DATE] >= @MinLogDate
						AND S.[CSD_START_WITHOUT_MS] = L.[LF_DATE]
				)

		ORDER BY CSD_DATE DESC;

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
