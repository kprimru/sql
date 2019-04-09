USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTROL_ADD]
	@CL_ID	INT,
	@TEXT	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;	

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
END