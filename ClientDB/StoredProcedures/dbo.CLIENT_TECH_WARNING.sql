USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_TECH_WARNING]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_TECH_WARNING]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_TECH_WARNING]
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
		SELECT CLientID, ClientFullName, ManagerName, CLM_DATE, CLM_STATUS
		FROM
			[dbo].[ClientList@Get?Write]()
			INNER JOIN dbo.ClaimTable ON CLM_ID_CLIENT = WCL_ID
			INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = CLM_ID_CLIENT
		WHERE (NOT CLM_STATUS IN  ('Отработана', 'Отклонена ответственным', 'Отменена', 'Отклонена', 'Выполнено успешно'))
			AND (IS_MEMBER('rl_tech_warning') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1)
		ORDER BY CLM_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_TECH_WARNING] TO rl_tech_warning;
GO
