﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_GROUP_UPDATE]
	@LIST			NVARCHAR(MAX),
	@MONTH			UNIQUEIDENTIFIER,
	@AVAILABILITY	UNIQUEIDENTIFIER,
	@WORK_STATE		UNIQUEIDENTIFIER,
	@CHARACTER		UNIQUEIDENTIFIER,
	@WORK_DATE		SMALLDATETIME,
	@PAPER_CARD		BIT = NULL,
	@POTENTIAL		UNIQUEIDENTIFIER = NULL,
	@REMOTE			UNIQUEIDENTIFIER = NULL,
	@PAY_CATEGORY	UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		BEGIN TRAN CompanyGroupUpdate

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER, NEW_ID UNIQUEIDENTIFIER)

		INSERT INTO Client.Company(
					ID_MASTER, SHORT, NAME, NUMBER, ID_PAY_CAT, ID_WORK_STATE, ID_POTENTIAL, ID_ACTIVITY, ACTIVITY_NOTE,
					ID_SENDER, SENDER_NOTE, ID_NEXT_MON, WORK_DATE, DELETE_COMMENT, ID_AVAILABILITY, ID_TAXING,
					ID_WORK_STATUS, ID_CHARACTER, ID_REMOTE, EMAIL, BLACK_LIST, BLACK_NOTE,
					STATUS, BDATE, EDATE, UPD_USER, WORK_BEGIN, CARD, PAPER_CARD)
			OUTPUT inserted.ID_MASTER, inserted.ID INTO @TBL
			SELECT
				c.ID, SHORT, NAME, NUMBER, ID_PAY_CAT, ID_WORK_STATE, ID_POTENTIAL, ID_ACTIVITY, ACTIVITY_NOTE,
				ID_SENDER, SENDER_NOTE, ID_NEXT_MON, WORK_DATE, DELETE_COMMENT, ID_AVAILABILITY, ID_TAXING,
				ID_WORK_STATUS, ID_CHARACTER, ID_REMOTE, EMAIL, BLACK_LIST, BLACK_NOTE,
				2, BDATE, EDATE, UPD_USER, WORK_BEGIN, CARD, PAPER_CARD
			FROM
				Client.Company c
				INNER JOIN Common.TableGUIDFromXML(@LIST) a ON c.ID = a.ID

		INSERT INTO Client.CompanyTaxing(ID_COMPANY, ID_TAXING)
			SELECT NEW_ID, ID_TAXING
			FROM
				Client.CompanyTaxing a
				INNER JOIN @TBL b ON a.ID_COMPANY = b.ID

		UPDATE c
		SET	ID_WORK_STATE	=	ISNULL(@WORK_STATE, ID_WORK_STATE),
			ID_NEXT_MON		=	ISNULL(@MONTH, ID_NEXT_MON),
			WORK_DATE		=	ISNULL(@WORK_DATE, WORK_DATE),
			ID_AVAILABILITY	=	ISNULL(@AVAILABILITY, ID_AVAILABILITY),
			ID_CHARACTER	=	ISNULL(@CHARACTER, ID_CHARACTER),
			PAPER_CARD		=	ISNULL(@PAPER_CARD, PAPER_CARD),
			ID_POTENTIAL	=	ISNULL(@POTENTIAL, ID_POTENTIAL),
			ID_REMOTE		=	ISNULL(@REMOTE, ID_REMOTE),
			ID_PAY_CAT		=	ISNULL(@PAY_CATEGORY, ID_PAY_CAT),
			BDATE			=	GETDATE(),
			UPD_USER		=	ORIGINAL_LOGIN()
		FROM
			Client.Company c
			INNER JOIN Common.TableGUIDFromXML(@LIST) a ON c.ID = a.ID

		EXEC Client.COMPANY_REINDEX NULL, @LIST

		COMMIT TRAN CompanyGroupUpdate
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyGroupUpdate
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
GRANT EXECUTE ON [Client].[COMPANY_GROUP_UPDATE] TO rl_company_group;
GO
