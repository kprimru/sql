USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_CONTROL_REMOVE]
	@ID			UNIQUEIDENTIFIER,
	@COMPANY	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY		
		BEGIN TRAN CompanyControl
		
		INSERT INTO Client.CompanyControl(ID_MASTER, ID_COMPANY, DATE, NOTIFY_DATE, 
						REMOVE_DATE, REMOVE_USER, NOTE, STATUS, BDATE, EDATE, UPD_USER)
			SELECT ID, ID_COMPANY, DATE, NOTIFY_DATE, 
				REMOVE_DATE, REMOVE_USER, NOTE, 2, BDATE, EDATE, UPD_USER
			FROM Client.CompanyControl
			WHERE ID = @ID OR ID IN (SELECT ID FROM Client.CompanyControlView WITH(NOEXPAND) WHERE ID_COMPANY = @COMPANY)


		UPDATE Client.CompanyControl
		SET REMOVE_DATE	=	GETDATE(),
			REMOVE_USER	=	ORIGINAL_LOGIN(),
			BDATE		=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID OR ID IN (SELECT ID FROM Client.CompanyControlView WITH(NOEXPAND) WHERE ID_COMPANY = @COMPANY)

		COMMIT TRAN CompanyControl
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyControl

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