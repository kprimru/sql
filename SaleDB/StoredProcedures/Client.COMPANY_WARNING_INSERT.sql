USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_WARNING_INSERT]
	@COMPANY		UNIQUEIDENTIFIER,
	@DATE			SMALLDATETIME,
	@NOTE			NVARCHAR(MAX),
	@NOTIFY_USER	NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN CompanyWarning

		IF @NOTIFY_USER IS NULL
			SET @NOTIFY_USER = ORIGINAL_LOGIN()

		INSERT INTO Client.CompanyWarning(ID_COMPANY, DATE, NOTIFY_USER, NOTE, CREATE_USER)
			VALUES(@COMPANY, @DATE, @NOTIFY_USER, @NOTE, ORIGINAL_LOGIN())
		
		COMMIT TRAN CompanyWarning
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyWarning

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
