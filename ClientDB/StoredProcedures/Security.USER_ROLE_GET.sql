USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[USER_ROLE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		b.name AS RL_NAME,
		CONVERT(BIT, 
			(
				SELECT COUNT(*)
				FROM sys.database_role_members d
				WHERE d.role_principal_id = b.principal_id 
					AND d.member_principal_id = @ID
			)
		) AS RL_SELECT
	FROM
		dbo.RoleTable a
		INNER JOIN sys.database_principals b ON name = RoleName
	ORDER BY RoleName
END