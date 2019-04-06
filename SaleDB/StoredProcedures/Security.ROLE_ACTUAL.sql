USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Security].[ROLE_ACTUAL]
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		SELECT a.name
		FROM 
			sys.database_principals a
			INNER JOIN sys.database_role_members b ON b.role_principal_id = a.principal_id
			INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
		WHERE c.name = ORIGINAL_LOGIN()

		UNION ALL
	
		SELECT e.name
		FROM 
			sys.database_principals a
			INNER JOIN sys.database_role_members b ON b.member_principal_id = a.principal_id
			INNER JOIN sys.database_principals c ON b.role_principal_id = c.principal_id
			INNER JOIN sys.database_role_members d ON d.member_principal_id = c.principal_id
			INNER JOIN sys.database_principals e ON d.role_principal_id = e.principal_id
		WHERE a.name = ORIGINAL_LOGIN()
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