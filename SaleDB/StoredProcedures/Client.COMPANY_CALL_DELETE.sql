USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_CALL_DELETE]
	@ID			UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	BEGIN TRY
		BEGIN TRAN CompanyCall

		DECLARE @COMPANY UNIQUEIDENTIFIER

		SELECT @COMPANY = ID_COMPANY
		FROM Client.Call
		WHERE ID = @ID

		INSERT INTO Client.Call(ID_MASTER, ID_COMPANY, ID_OFFICE, ID_PERSONAL, CL_PERSONAL, DATE, NOTE, STATUS, BDATE, EDATE, UPD_USER, CONTROL, DUTY)
			SELECT ID, ID_COMPANY, ID_OFFICE, ID_PERSONAL, CL_PERSONAL, DATE, NOTE, 2, BDATE, EDATE, UPD_USER, CONTROL, DUTY
			FROM Client.Call
			WHERE ID = @ID

		UPDATE Client.Call
		SET STATUS = 3,
			EDATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID

		EXEC Client.COMPANY_REINDEX @COMPANY, NULL

		COMMIT TRAN CompanyCall
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyCall

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