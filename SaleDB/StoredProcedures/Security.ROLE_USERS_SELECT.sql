USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[ROLE_USERS_SELECT]
	@ROLE	NVARCHAR(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		SELECT 
			0 AS TP, CAPTION, NAME,
			CONVERT(BIT, ISNULL((
				SELECT COUNT(*)
				FROM 
					sys.database_principals a
					INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
					INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
				WHERE a.NAME = @ROLE AND c.NAME = z.NAME
			), 0)) AS CHECKED
		FROM Security.RoleGroup z

		UNION ALL

		SELECT 
			1 AS TP, NAME, LOGIN,
			CONVERT(BIT, ISNULL((
				SELECT COUNT(*)
				FROM 
					sys.database_principals a
					INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
					INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
				WHERE a.NAME = @ROLE AND c.NAME = z.LOGIN
			), 0))
		FROM Security.Users z
		WHERE z.STATUS = 1
		
		ORDER BY TP, CAPTION
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