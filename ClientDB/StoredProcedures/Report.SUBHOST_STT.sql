USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[SUBHOST_STT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[SUBHOST_STT]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[SUBHOST_STT]
	@PARAM	NVARCHAR(MAX) = NULL
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
			SH_NAME AS [Подхост], DATE AS [Дата загрузки], USR AS [Пользователь],
			dbo.FileByteSizeToStr(DATALENGTH(BIN)) AS [Размер],
			PROCESS AS [Дата обработки]
		FROM
			Subhost.STTFiles a
			INNER JOIN dbo.Subhost b ON SH_ID = ID_SUBHOST
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[SUBHOST_STT] TO rl_report;
GO
