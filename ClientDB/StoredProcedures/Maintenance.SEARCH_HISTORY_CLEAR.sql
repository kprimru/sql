USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[SEARCH_HISTORY_CLEAR]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[SEARCH_HISTORY_CLEAR]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[SEARCH_HISTORY_CLEAR]
	@DATE	SMALLDATETIME = NULL
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

		IF @DATE IS NULL
			TRUNCATE TABLE dbo.ClientSearchFiles
		ELSE
			DELETE
			FROM dbo.ClientSearchFiles
			WHERE CSF_DATE < @DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[SEARCH_HISTORY_CLEAR] TO rl_maintenance;
GO
