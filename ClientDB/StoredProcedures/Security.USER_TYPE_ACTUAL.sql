USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[USER_TYPE_ACTUAL]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT UT_ROLE
	FROM 
		Security.UserType
		INNER JOIN sys.database_principals a ON UT_ROLE = a.name
		INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
		INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
	WHERE c.name = ORIGINAL_LOGIN()
END