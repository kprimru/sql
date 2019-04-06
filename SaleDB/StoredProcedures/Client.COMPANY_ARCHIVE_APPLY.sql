USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_ARCHIVE_APPLY]
	@ID				UNIQUEIDENTIFIER,
	@POTENTIAL		UNIQUEIDENTIFIER,
	@NEXT_MON		UNIQUEIDENTIFIER,
	@AVAILABILITY	UNIQUEIDENTIFIER,
	@CHARACTER		UNIQUEIDENTIFIER = NULL,
	@PAY_CAT		UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN CompanyArchive
		
		DECLARE @COMPANY	UNIQUEIDENTIFIER
		
		SELECT @COMPANY = ID_COMPANY
		FROM Client.CompanyArchive
		WHERE ID = @ID
		
		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
		
		INSERT INTO Client.Company(
							ID_MASTER, SHORT, NAME, NUMBER, ID_PAY_CAT, ID_WORK_STATE, ID_POTENTIAL, ID_ACTIVITY, ACTIVITY_NOTE, 
							ID_SENDER, SENDER_NOTE, ID_NEXT_MON, WORK_DATE, DELETE_COMMENT, ID_AVAILABILITY, ID_TAXING, 
							ID_WORK_STATUS, ID_CHARACTER, ID_REMOTE, EMAIL, BLACK_LIST, BLACK_NOTE, CARD, STATUS, BDATE, EDATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT 
				ID, SHORT, NAME, NUMBER, ID_PAY_CAT, ID_WORK_STATE, ID_POTENTIAL, ID_ACTIVITY, ACTIVITY_NOTE, 
				ID_SENDER, SENDER_NOTE, ID_NEXT_MON, WORK_DATE, DELETE_COMMENT, ID_AVAILABILITY, ID_TAXING, 
				ID_WORK_STATUS, ID_CHARACTER, ID_REMOTE, EMAIL, BLACK_LIST, BLACK_NOTE, CARD, 2, BDATE, EDATE, UPD_USER
			FROM Client.Company
			WHERE ID = @COMPANY

		DECLARE @NEW_ID UNIQUEIDENTIFIER
		
		SELECT @NEW_ID = ID
		FROM @TBL
		
		INSERT INTO Client.CompanyTaxing(ID_COMPANY, ID_TAXING)
			SELECT @NEW_ID, ID_TAXING
			FROM Client.CompanyTaxing
			WHERE ID_COMPANY = @COMPANY
			
		INSERT INTO Client.CompanyActivity(ID_COMPANY, ID_ACTIVITY)
			SELECT @NEW_ID, ID_ACTIVITY
			FROM Client.CompanyActivity
			WHERE ID_COMPANY = @COMPANY

		DECLARE @WS UNIQUEIDENTIFIER		

		SELECT @WS = ID
		FROM Client.WorkState
		WHERE ARCHIVE_AUTO = 1

		UPDATE Client.Company
		SET	ID_POTENTIAL	=	@POTENTIAL,
			ID_NEXT_MON		=	@NEXT_MON,
			ID_AVAILABILITY	=	@AVAILABILITY,
			ID_CHARACTER	=	@CHARACTER,
			ID_WORK_STATE	=	ISNULL(@WS, ID_WORK_STATE),
			ID_PAY_CAT		=	@PAY_CAT,
			BDATE			=	GETDATE(),
			UPD_USER		=	ORIGINAL_LOGIN()
		WHERE	ID	=	@COMPANY	
		
		INSERT INTO Client.CompanyArchive(ID_MASTER, ID_COMPANY, ID_POTENTIAL, ID_NEXT_MON, ID_AVAILABILITY, STATUS, BDATE, EDATE, UPD_USER)
			SELECT ID, ID_COMPANY, ID_POTENTIAL, ID_NEXT_MON, ID_AVAILABILITY, 2, BDATE, EDATE, UPD_USER
			FROM Client.CompanyArchive
			WHERE ID_COMPANY = @COMPANY
				AND STATUS = 1
				
		UPDATE Client.CompanyArchive
		SET ID_POTENTIAL	=	ISNULL(@POTENTIAL, ID_POTENTIAL),
			ID_NEXT_MON		=	ISNULL(@NEXT_MON, ID_NEXT_MON),
			ID_AVAILABILITY	=	ISNULL(@AVAILABILITY, ID_AVAILABILITY),
			ID_CHARACTER	=	ISNULL(@CHARACTER, ID_CHARACTER),
			ID_PAY_CAT		=	ISNULL(@PAY_CAT, ID_PAY_CAT),
			STATUS			=	4,
			BDATE			=	GETDATE(),			
			UPD_USER		=	ORIGINAL_LOGIN()
		WHERE ID_COMPANY = @COMPANY
			AND STATUS = 1
				
		DECLARE @CO_XML NVARCHAR(MAX)
		
		SET @CO_XML = N'<root><item id="' + CONVERT(NVARCHAR(50), @COMPANY) + '" /></root>'
				
		EXEC Client.COMPANY_PROCESS_MANAGER_RETURN @CO_XML
		EXEC Client.COMPANY_PROCESS_SALE_RETURN @CO_XML
		EXEC Client.COMPANY_PROCESS_PHONE_RETURN @CO_XML
				
		EXEC Client.COMPANY_REINDEX @COMPANY, NULL
				
		COMMIT TRAN CompanyArchive
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyArchive
		
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