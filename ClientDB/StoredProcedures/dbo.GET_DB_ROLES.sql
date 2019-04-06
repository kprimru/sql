USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GET_DB_ROLES]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON

	SELECT DbRole = b.name, MemberName = d.name, MemberSID = d.sid
	FROM 
		dbo.RoleTable a
		INNER JOIN sys.database_principals b ON a.RoleName = b.name		
		INNER JOIN sys.database_role_members c ON b.principal_id = c.role_principal_id
		INNER JOIN sys.database_principals d ON d.principal_id = c.member_principal_id
	WHERE b.Name <> 'DBStatistic' /*AND d.name = ORIGINAL_LOGIN()*/
	ORDER BY d.Name
END