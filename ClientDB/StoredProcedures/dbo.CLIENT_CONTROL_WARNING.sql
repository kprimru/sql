USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTROL_WARNING]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTROL_WARNING]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_CONTROL_WARNING]
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

		SELECT ClientID, ClientFullName, ManagerName, CC_TEXT, CC_DATE, CC_BEGIN
		FROM
			[dbo].[ClientList@Get?Write]()
			INNER JOIN dbo.ClientControl a ON CC_ID_CLIENT = WCL_ID
			INNER JOIN dbo.ClientTable b ON ClientID = CC_ID_CLIENT
			INNER JOIN dbo.ServiceTable c ON c.ServiceID = ClientServiceID
			INNER JOIN dbo.ManagerTable d ON c.ManagerID = d.ManagerID
		WHERE /*CC_READ_DATE IS NULL AND */CC_REMOVE_DATE IS NULL
			AND (CC_BEGIN IS NULL OR CC_BEGIN <= GETDATE())
			AND (IS_MEMBER('rl_control_warning') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1)
		ORDER BY ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTROL_WARNING] TO rl_control_warning;
GO
