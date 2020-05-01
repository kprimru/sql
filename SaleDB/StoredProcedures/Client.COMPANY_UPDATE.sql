USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_UPDATE]
	@ID				UNIQUEIDENTIFIER,
	@SHORT			NVARCHAR(128),
	@NAME			NVARCHAR(448),
	@NUMBER			INT,
	@PAY_CAT		UNIQUEIDENTIFIER,
	@WORK_STATE		UNIQUEIDENTIFIER,
	@POTENTIAL		UNIQUEIDENTIFIER,
	@ACTIVITY		UNIQUEIDENTIFIER,
	@ACTIVITY_NOTE	NVARCHAR(MAX),
	@SENDER			UNIQUEIDENTIFIER,
	@SENDER_NOTE	NVARCHAR(MAX),
	@NEXT_MON		UNIQUEIDENTIFIER,
	@WORK_DATE		SMALLDATETIME,
	@DELETE_COMMENT	NVARCHAR(256),
	@AVAILABILITY	UNIQUEIDENTIFIER,
	@TAXING			UNIQUEIDENTIFIER,
	@WORK_STATUS	UNIQUEIDENTIFIER,
	@CHARACTER		UNIQUEIDENTIFIER,
	@REMOTE			UNIQUEIDENTIFIER,
	@EMAIL			NVARCHAR(512),
	@BLACK_LIST		BIT,
	@BLACK_NOTE		NVARCHAR(MAX),
	@WORK_BEGIN		SMALLDATETIME = NULL,
	@CARD			TINYINT = NULL,
	@PAPER_CARD		BIT = NULL,
	@TAXING_LIST	NVARCHAR(MAX) = NULL,
	@ACTIVITY_LIST	NVARCHAR(MAX) = NULL,
	@PROJECT		UNIQUEIDENTIFIER = NULL,
	@PROJECT_LIST	NVARCHAR(MAX) = NULL,
	@DEPO			BIT = 0,
	@DEPO_NUM		INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN Company

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO Client.Company(
							ID_MASTER, SHORT, NAME, NUMBER, ID_PAY_CAT, ID_WORK_STATE, ID_POTENTIAL, ID_ACTIVITY, ACTIVITY_NOTE,
							ID_SENDER, SENDER_NOTE, ID_NEXT_MON, WORK_DATE, DELETE_COMMENT, ID_AVAILABILITY, ID_TAXING,
							ID_WORK_STATUS, ID_CHARACTER, ID_REMOTE, EMAIL, BLACK_LIST, BLACK_NOTE, WORK_BEGIN, CARD, PAPER_CARD,
							ID_PROJECT, STATUS, BDATE, EDATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT
				ID, SHORT, NAME, NUMBER, ID_PAY_CAT, ID_WORK_STATE, ID_POTENTIAL, ID_ACTIVITY, ACTIVITY_NOTE,
				ID_SENDER, SENDER_NOTE, ID_NEXT_MON, WORK_DATE, DELETE_COMMENT, ID_AVAILABILITY, ID_TAXING,
				ID_WORK_STATUS, ID_CHARACTER, ID_REMOTE, EMAIL, BLACK_LIST, BLACK_NOTE, WORK_BEGIN, CARD, PAPER_CARD,
				ID_PROJECT, 2, BDATE, EDATE, UPD_USER
			FROM Client.Company
			WHERE ID = @ID

		DECLARE @NEW_ID UNIQUEIDENTIFIER

		SELECT @NEW_ID = ID
		FROM @TBL

		INSERT INTO Client.CompanyTaxing(ID_COMPANY, ID_TAXING)
			SELECT @NEW_ID, ID_TAXING
			FROM Client.CompanyTaxing
			WHERE ID_COMPANY = @ID

		INSERT INTO Client.CompanyProject(ID_COMPANY, ID_PROJECT)
			SELECT @NEW_ID, ID_PROJECT
			FROM Client.CompanyProject
			WHERE ID_COMPANY = @ID

		INSERT INTO Client.CompanyActivity(ID_COMPANY, ID_ACTIVITY)
			SELECT @NEW_ID, ID_ACTIVITY
			FROM Client.CompanyActivity
			WHERE ID_COMPANY = @ID

		UPDATE Client.Company
		SET	SHORT			=	@SHORT,
			NAME			=	@NAME,
			NUMBER			=	@NUMBER,
			ID_PAY_CAT		=	@PAY_CAT,
			ID_WORK_STATE	=	@WORK_STATE,
			ID_POTENTIAL	=	@POTENTIAL,
			ID_ACTIVITY		=	@ACTIVITY,
			ACTIVITY_NOTE	=	@ACTIVITY_NOTE,
			ID_SENDER		=	@SENDER,
			SENDER_NOTE		=	@SENDER_NOTE,
			ID_NEXT_MON		=	@NEXT_MON,
			WORK_DATE		=	CASE WHEN @WORK_DATE < WORK_DATE THEN WORK_DATE ELSE @WORK_DATE END,
			DELETE_COMMENT	=	@DELETE_COMMENT,
			ID_AVAILABILITY	=	@AVAILABILITY,
			ID_TAXING		=	@TAXING,
			ID_WORK_STATUS	=	@WORK_STATUS,
			ID_CHARACTER	=	@CHARACTER,
			ID_REMOTE		=	@REMOTE,
			EMAIL			=	@EMAIL,
			BLACK_LIST		=	@BLACK_LIST,
			BLACK_NOTE		=	@BLACK_NOTE,
			WORK_BEGIN		=	@WORK_BEGIN,
			CARD			=	@CARD,
			PAPER_CARD		=	@PAPER_CARD,
			ID_PROJECT		=	@PROJECT,
			BDATE			=	GETDATE(),
			UPD_USER		=	ORIGINAL_LOGIN()
		WHERE	ID	=	@ID

		DELETE FROM Client.CompanyTaxing WHERE ID_COMPANY = @ID

		INSERT INTO Client.CompanyTaxing(ID_COMPANY, ID_TAXING)
			SELECT @ID, ID
			FROM Common.TableGUIDFromXML(@TAXING_LIST)

		DELETE FROM Client.CompanyProject WHERE ID_COMPANY = @ID

		INSERT INTO Client.CompanyProject(ID_COMPANY, ID_PROJECT)
			SELECT @ID, ID
			FROM Common.TableGUIDFromXML(@PROJECT_LIST)

		DELETE FROM Client.CompanyActivity WHERE ID_COMPANY = @ID

		INSERT INTO Client.CompanyActivity(ID_COMPANY, ID_ACTIVITY)
			SELECT @ID, ID
			FROM Common.TableGUIDFromXML(@ACTIVITY_LIST)

		EXEC Client.COMPANY_REINDEX @ID, NULL

		COMMIT TRAN Company
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN Company

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
GRANT EXECUTE ON [Client].[COMPANY_UPDATE] TO rl_company_w;
GO