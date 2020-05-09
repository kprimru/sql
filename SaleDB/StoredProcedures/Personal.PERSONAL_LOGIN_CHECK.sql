USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_LOGIN_CHECK]
	@LOGIN		NVARCHAR(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF LTRIM(RTRIM(@LOGIN)) = N''
			SELECT '�� ������ �����' AS ERROR
		ELSE IF EXISTS(SELECT * FROM sys.server_principals WHERE name = @LOGIN)
			SELECT '����� "' + @LOGIN + '" ��� ������������ �� �������. �������� ������ ���' AS ERROR
		ELSE IF EXISTS(SELECT * FROM sys.database_principals WHERE name = @LOGIN)
			SELECT '������������ "' + @LOGIN + '" ��� ������������ � ���� ������. �������� ������ ���' AS ERROR
		ELSE
			SELECT '' AS ERROR
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
GO
GRANT EXECUTE ON [Personal].[PERSONAL_LOGIN_CHECK] TO rl_personal_r;
GO