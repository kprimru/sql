USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_AUDIT_WARNING]
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
		SELECT ClientID, ClientFullName, ServiceName, ManagerName
		FROM
			dbo.ClientAudit
			INNER JOIN dbo.ClientTable a ON CA_ID_CLIENT = ClientID
			INNER JOIN [dbo].[ClientList@Get?Write]() ON WCL_ID = ClientID
			INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
			INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
		WHERE CA_CONTROL = 1 AND a.STATUS = 1
		ORDER BY CA_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_AUDIT_WARNING] TO rl_audit_warning;
GO