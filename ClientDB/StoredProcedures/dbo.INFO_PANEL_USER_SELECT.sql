USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INFO_PANEL_USER_SELECT]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT a.ID, TEXT
	FROM 
		dbo.InfoPanel a
		INNER JOIN dbo.InfoPanelUser b ON a.ID = b.ID_PANEL
	WHERE STATUS = 1 
		AND 
			(
				b.USR_NAME = ORIGINAL_LOGIN()
				OR
				EXISTS
					(
						SELECT *
						FROM 
							sys.database_principals z
							INNER JOIN sys.database_role_members y ON z.principal_id = y.member_principal_id
							INNER JOIN sys.database_principals x ON x.principal_id = y.role_principal_id
						WHERE z.name = ORIGINAL_LOGIN() AND x.name = b.USR_NAME
					)
			)
			
	UNION ALL
	
	SELECT NULL, 'Размер БД близится к своему лимиту (' + CONVERT(VARCHAR(20), CONVERT(FLOAT, ROUND((
		SELECT SUM(data + index_size)/1024.0/1024/1024
		FROM Maintenance.DatabaseSize()		
	), 2))) + ' Гб из 4 Гб)'
	WHERE @@VERSION LIKE '%Express Edition%' AND (
		SELECT SUM(data + index_size)/1024.0/1024/1024
		FROM Maintenance.DatabaseSize()		
	) > 3.8 AND (IS_SRVROLEMEMBER('sysadmin') = 1 OR IS_MEMBER('db_owner') = 1 OR IS_MEMBER('DBChief') = 1)
END