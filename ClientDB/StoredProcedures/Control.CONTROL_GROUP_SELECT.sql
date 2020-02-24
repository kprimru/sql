USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Control].[CONTROL_GROUP_SELECT]
	@FILTER NVARCHAR(256) = NULL
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

		SELECT ID, NAME, PSEDO
		FROM Control.ControlGroup
		WHERE
			(PSEDO = 'MANAGER' AND (IS_MEMBER('rl_control_manager') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
			OR
			(PSEDO = 'LAW' AND (IS_MEMBER('rl_control_law') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
			OR
			(PSEDO = 'DUTY' AND (IS_MEMBER('rl_control_duty') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
			OR
			(PSEDO = 'AUDIT' AND (IS_MEMBER('rl_control_audit') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
			OR
			(PSEDO = 'CHIEF' AND (IS_MEMBER('rl_control_chief') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
			OR
			(PSEDO = 'TEACHER' AND (IS_MEMBER('rl_control_teacher') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1))
		ORDER BY NAME
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
