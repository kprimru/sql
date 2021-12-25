USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COURIER_SELECT]
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

	    SELECT
		    ServiceID, ServiceName, a.ManagerID, ManagerName, ServiceFullName,
		    (
			    SELECT COUNT(*)
			    FROM [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable
			    WHERE ClientServiceID = ServiceID
		    ) AS ServiceCount
	    FROM
		    [PC275-SQL\ALPHA].ClientDB.dbo.ServiceTable a INNER JOIN
		    [PC275-SQL\ALPHA].ClientDB.dbo.ManagerTable b ON a.ManagerID = b.ManagerID
	    ORDER BY ServiceName

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Client].[COURIER_SELECT] TO rl_common;
GO
