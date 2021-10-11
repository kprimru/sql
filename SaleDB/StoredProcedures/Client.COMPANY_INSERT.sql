USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_INSERT]
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
	@WORK_BEGIN		SMALLDATETIME,
	@ID				UNIQUEIDENTIFIER = NULL OUTPUT,
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

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO Client.Company(
				SHORT, NAME, NUMBER, ID_PAY_CAT, ID_WORK_STATE, ID_POTENTIAL, ID_ACTIVITY, ACTIVITY_NOTE,
				ID_SENDER, SENDER_NOTE, ID_NEXT_MON, WORK_DATE, DELETE_COMMENT, ID_AVAILABILITY, ID_TAXING,
				ID_WORK_STATUS, ID_CHARACTER, ID_REMOTE, EMAIL, BLACK_LIST, BLACK_NOTE, WORK_BEGIN, CARD, PAPER_CARD, ID_PROJECT)
			OUTPUT inserted.ID INTO @TBL
			VALUES(
				@SHORT, @NAME, @NUMBER, @PAY_CAT, @WORK_STATE, @POTENTIAL, @ACTIVITY, @ACTIVITY_NOTE,
				@SENDER, @SENDER_NOTE, @NEXT_MON, @WORK_DATE, @DELETE_COMMENT, @AVAILABILITY, @TAXING,
				@WORK_STATUS, @CHARACTER, @REMOTE, @EMAIL, @BLACK_LIST, @BLACK_NOTE, @WORK_BEGIN, @CARD, @PAPER_CARD, @PROJECT)

		SELECT @ID = ID FROM @TBL

		INSERT INTO Client.CompanyTaxing(ID_COMPANY, ID_TAXING)
			SELECT @ID, ID
			FROM Common.TableGUIDFromXML(@TAXING_LIST)

		INSERT INTO Client.CompanyProject(ID_COMPANY, ID_PROJECT)
			SELECT @ID, ID
			FROM Common.TableGUIDFromXML(@PROJECT_LIST)

		INSERT INTO Client.CompanyActivity(ID_COMPANY, ID_ACTIVITY)
			SELECT @ID, ID
			FROM Common.TableGUIDFromXML(@ACTIVITY_LIST)

		EXEC Client.COMPANY_REINDEX @ID, NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_INSERT] TO rl_company_w;
GO
