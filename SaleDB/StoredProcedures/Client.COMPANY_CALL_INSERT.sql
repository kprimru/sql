USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Client].[COMPANY_CALL_INSERT]
	@COMPANY		UNIQUEIDENTIFIER,
	@OFFICE			UNIQUEIDENTIFIER,
	@PERSONAL		UNIQUEIDENTIFIER,
	@CL_PERSONAL	NVARCHAR(512),
	@DATE			SMALLDATETIME,
	@NOTE			NVARCHAR(MAX),
	@ID				UNIQUEIDENTIFIER = NULL OUTPUT,
	@NEXT			SMALLDATETIME = NULL,
	@WARN_ID		UNIQUEIDENTIFIER = NULL,
	@WARN_ACTION	INT = NULL,
	@WARN_DATE		SMALLDATETIME = NULL,
	@WARN_NOTE		NVARCHAR(MAX) = NULL,
	@CONTROL		BIT = 0,
	@DUTY			BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	BEGIN TRY
		BEGIN TRAN CompanyCall

		INSERT INTO Client.Call(ID_COMPANY, ID_OFFICE, ID_PERSONAL, CL_PERSONAL, DATE, NOTE, CONTROL, DUTY)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@COMPANY, @OFFICE, @PERSONAL, @CL_PERSONAL, @DATE, @NOTE, @CONTROL, @DUTY)

		SELECT @ID = ID FROM @TBL

		UPDATE Client.Company
		SET WORK_DATE = Common.DateOf(@DATE)
		WHERE ID = @COMPANY
		
		EXEC Client.CALL_DATE_CHANGE @COMPANY, @NEXT

		EXEC Client.COMPANY_REINDEX @COMPANY, NULL
	
		IF @WARN_ID IS NOT NULL 
		BEGIN
			INSERT INTO Client.CompanyWarning(ID_MASTER, ID_COMPANY, DATE, NOTIFY_USER, NOTE, END_DATE, CREATE_USER, STATUS, UPD_DATE, UPD_USER)
				SELECT @WARN_ID, ID_COMPANY, DATE, NOTIFY_USER, NOTE, END_DATE, CREATE_USER, 2, UPD_DATE, UPD_USER
				FROM Client.CompanyWarning
				WHERE ID = @WARN_ID
			
			IF @WARN_ACTION = 1			
				UPDATE Client.CompanyWarning
				SET END_DATE = GETDATE(),
					UPD_DATE = GETDATE(),
					UPD_USER = ORIGINAL_LOGIN()
				WHERE ID = @WARN_ID
			ELSE IF @WARN_ACTION = 0
				UPDATE Client.CompanyWarning
				SET DATE = @WARN_DATE,
					NOTE = @WARN_NOTE,
					UPD_DATE = GETDATE(),
					UPD_USER = ORIGINAL_LOGIN()
				WHERE ID = @WARN_ID
		END
	
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