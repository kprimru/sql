USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[SERVICE_TYPE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[SERVICE_TYPE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[SERVICE_TYPE_SELECT]
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

	    SELECT ServiceTypeName, ServiceTypeID
	    FROM [PC275-SQL\ALPHA].ClientDB.dbo.ServiceTypeTable
	    ORDER BY ServiceTypeName

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Client].[SERVICE_TYPE_SELECT] TO rl_common;
GO
