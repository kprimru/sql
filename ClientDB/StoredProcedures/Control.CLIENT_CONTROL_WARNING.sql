USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Control].[CLIENT_CONTROL_WARNING]
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
		SELECT --ClientID, ClientFullName, ManagerName, CC_TEXT, CC_DATE, CC_BEGIN
			ClientID, ClientFullName, AUTHOR, c.NAME, a.NOTE, a.DATE, a.NOTIFY
		FROM
			Control.ClientControl a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON ClientID = ID_CLIENT
			LEFT OUTER JOIN Control.ControlGroup c ON a.ID_GROUP = c.ID
		WHERE REMOVE_DATE IS NULL
			AND (NOTIFY IS NULL OR NOTIFY <= GETDATE())
			AND (
					RECEIVER = ORIGINAL_LOGIN()
					OR
					(c.PSEDO = 'MANAGER' AND (IS_MEMBER('rl_control_manager') = 1 AND ID_CLIENT IN (SELECT WCL_ID FROM [dbo].[ClientList@Get?Write]()) OR IS_SRVROLEMEMBER('sysadmin') = 1))
					OR
					(c.PSEDO = 'LAW' AND (IS_MEMBER('rl_control_law') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
					OR
					(c.PSEDO = 'DUTY' AND (IS_MEMBER('rl_control_duty') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
					OR
					(c.PSEDO = 'AUDIT' AND (IS_MEMBER('rl_control_audit') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
					OR
					(c.PSEDO = 'CHIEF' AND (IS_MEMBER('rl_control_chief') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
					OR
					(c.PSEDO = 'TEACHER' AND (IS_MEMBER('rl_control_teacher') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
				)
		ORDER BY ClientFullName;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Control].[CLIENT_CONTROL_WARNING] TO rl_control_chief;
GRANT EXECUTE ON [Control].[CLIENT_CONTROL_WARNING] TO rl_control_duty;
GRANT EXECUTE ON [Control].[CLIENT_CONTROL_WARNING] TO rl_control_law;
GRANT EXECUTE ON [Control].[CLIENT_CONTROL_WARNING] TO rl_control_manager;
GRANT EXECUTE ON [Control].[CLIENT_CONTROL_WARNING] TO rl_control_teacher;
GO