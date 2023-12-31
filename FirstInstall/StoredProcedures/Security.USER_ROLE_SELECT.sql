USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_ROLE_SELECT]
	@RL_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		UR_STATUS, RL_ID, US_ID_MASTER, US_NAME,
		CASE
			WHEN RM_ID IS NULL THEN CAST(0 AS BIT)
			ELSE CAST (1 AS BIT)
		END AS RM_MESSAGE
	FROM
		Security.UserRoleView LEFT OUTER JOIN
		Security.RoleMessages ON RM_ID_ROLE = RL_ID AND RM_ID_USER = US_ID_MASTER
	WHERE RL_ID = @RL_ID
END
GO
