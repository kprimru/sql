USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTROL_WARNING_LAST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTROL_WARNING_LAST]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTROL_WARNING_LAST]
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

		SELECT MAX(CC_DATE) AS LAST_DATE
		FROM
			[dbo].[ClientList@Get?Write]()
			INNER JOIN dbo.ClientControl a ON CC_ID_CLIENT = WCL_ID
			INNER JOIN dbo.ClientTable b ON ClientID = CC_ID_CLIENT
			INNER JOIN dbo.ServiceTable c ON c.ServiceID = ClientServiceID
			INNER JOIN dbo.ManagerTable d ON d.ManagerID = c.ManagerID
		WHERE CC_READ_DATE IS NULL
			AND IS_MEMBER('rl_control_warning') = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTROL_WARNING_LAST] TO rl_control_warning;
GO
