USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Security].[USER_SELECT]
	@FILTER	NVARCHAR(256) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY
		SELECT 
			a.ID, a.LOGIN, a.NAME,
			REVERSE(STUFF(REVERSE((
				SELECT CAPTION + ', '
				FROM 
					Security.RoleGroup c
					INNER JOIN sys.database_principals d ON c.NAME = d.NAME
					INNER JOIN sys.database_role_members e ON e.role_principal_id = d.principal_id
					INNER JOIN sys.database_principals f ON e.member_principal_id = f.principal_id
				WHERE f.NAME = a.LOGIN
				ORDER BY CAPTION FOR XML PATH('')
			)), 1, 2, '')) AS GROUPS
		FROM 
			Security.Users a
			LEFT OUTER JOIN sys.database_principals b ON a.LOGIN = b.NAME
		WHERE a.STATUS = 1
			AND
				(
					@FILTER IS NULL
					OR a.LOGIN LIKE @FILTER
					OR a.NAME LIKE @FILTER
				)
		ORDER BY a.NAME
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT 
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END