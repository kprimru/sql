USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Control].[USER_SELECT]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT US_NAME
	FROM Security.RoleUserView
	WHERE RL_NAME IN
		(
			SELECT RL_NAME
			FROM Security.RoleUserView
			WHERE US_NAME = ORIGINAL_LOGIN()
				AND RL_NAME IN
					(
						'rl_control_manager',
						'rl_control_law',
						'rl_control_duty',
						'rl_control_audit',
						'rl_control_chief',
						'rl_control_teacher'
					)
		)
	ORDER BY US_NAME	
END
