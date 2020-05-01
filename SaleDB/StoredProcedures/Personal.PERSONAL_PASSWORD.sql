USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_PASSWORD]
	@ID		UNIQUEIDENTIFIER,
	@PASS	NVARCHAR(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @LOGIN	NVARCHAR(128)

		SELECT @LOGIN = LOGIN
		FROM Personal.OfficePersonal
		WHERE ID = @ID

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'ALTER LOGIN ' + QUOTENAME(@LOGIN) + ' WITH PASSWORD = ' + QUOTENAME(@PASS, '''')
		EXEC (@SQL)
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
GRANT EXECUTE ON [Personal].[PERSONAL_PASSWORD] TO rl_user_w;
GO