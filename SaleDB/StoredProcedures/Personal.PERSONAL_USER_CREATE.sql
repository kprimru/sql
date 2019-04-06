USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Personal].[PERSONAL_USER_CREATE]
	@ID			UNIQUEIDENTIFIER,
	@LOGIN		NVARCHAR(128),
	@PASS		NVARCHAR(128),
	@ROLE		UNIQUEIDENTIFIER	
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		DECLARE @SHORT NVARCHAR(128)

		SELECT @SHORT = SHORT
		FROM Personal.OfficePersonal
		WHERE ID = @ID

		UPDATE Personal.OfficePersonal
		SET LOGIN	=	@LOGIN,
			PASS	=	@PASS
		WHERE ID = @ID

		IF @LOGIN IS NOT NULL AND @PASS IS NOT NULL
			EXEC Security.USER_CREATE 2, @LOGIN, @SHORT, @PASS, @ROLE
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