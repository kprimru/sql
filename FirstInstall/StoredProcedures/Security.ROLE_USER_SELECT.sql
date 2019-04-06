USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[ROLE_USER_SELECT]
	@US_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @US_LOGIN	VARCHAR(50)

	SELECT @US_LOGIN = US_LOGIN
	FROM Security.UserActive
	WHERE US_ID_MASTER = @US_ID
	/*
	SELECT 
		UR_STATUS, a.RL_ID, RL_ID_MASTER, RL_NAME, a.RL_ROLE, ROLE_CREATE
	FROM 
		Security.RoleActive a LEFT OUTER JOIN		
		Security.UserRoleView b ON a.RL_ID = b.RL_ID
	WHERE US_LOGIN = @US_LOGIN
	*/
	SELECT 
		UR_STATUS, a.RL_ID, RL_ID_MASTER, RL_NAME, a.RL_ROLE, ROLE_CREATE, 
		CASE 
			WHEN RM_ID IS NULL THEN CAST(0 AS BIT)
			ELSE CAST(1 AS BIT)
		END AS RM_MESSAGE
	FROM 
		Security.RoleActive a LEFT OUTER JOIN		
		(
			SELECT 
				RL_ID, RL_ROLE, US_ID_MASTER, US_NAME, US_LOGIN,
				Security.UserRoleStatus(US_LOGIN, RL_ID) AS UR_STATUS
			FROM 
				Security.Roles CROSS JOIN
				Security.UserLast
			WHERE US_LOGIN = @US_LOGIN
		) b ON a.RL_ID = b.RL_ID LEFT OUTER JOIN
		Security.RoleMessages ON RM_ID_ROLE = a.RL_ID AND RM_ID_USER = US_ID_MASTER
END
