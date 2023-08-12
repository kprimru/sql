USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONTROL_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONTROL_ADD]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CONTROL_ADD]
	@CL_ID	INT,
	@TEXT	VARCHAR(MAX)
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

		IF	IS_MEMBER('rl_client_control_manager_set') = 0
			AND IS_MEMBER('rl_client_control_chief_set') = 0
			AND IS_SRVROLEMEMBER('sysadmin') = 0
			AND IS_MEMBER('rl_client_control_duty_set') = 0
			AND IS_MEMBER('rl_client_control_quality_set') = 0
			AND IS_MEMBER('rl_client_control_lawyer_set') = 0
		BEGIN
			RAISERROR ('Вам запрещено ставить клиента на контроль', 16, 1)

			RETURN
		END

		INSERT INTO dbo.ClientControl(CC_ID_CLIENT, CC_TEXT, CC_TYPE)
			SELECT
				@CL_ID, @TEXT,
				CASE
					WHEN IS_MEMBER('rl_client_control_quality_set') = 1 THEN 1
					WHEN IS_MEMBER('rl_client_control_manager_set') = 1 THEN 2
					WHEN IS_MEMBER('rl_client_control_duty_set') = 1 THEN 3
					WHEN IS_MEMBER('rl_client_control_chief_set') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1 THEN 4
					WHEN IS_MEMBER('rl_client_control_lawyer_set') = 1 THEN 5
					ELSE NULL
				END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONTROL_ADD] TO rl_client_control_chief_set;
GRANT EXECUTE ON [dbo].[CONTROL_ADD] TO rl_client_control_duty_set;
GRANT EXECUTE ON [dbo].[CONTROL_ADD] TO rl_client_control_lawyer_set;
GRANT EXECUTE ON [dbo].[CONTROL_ADD] TO rl_client_control_manager_set;
GRANT EXECUTE ON [dbo].[CONTROL_ADD] TO rl_client_control_quality_set;
GO
