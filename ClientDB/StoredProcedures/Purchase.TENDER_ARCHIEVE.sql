USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Purchase].[TENDER_ARCHIEVE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @NEWID	UNIQUEIDENTIFIER

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO Purchase.Tender(TD_ID_MASTER, TD_ID_CLIENT, TD_NOTICE_NUM, TD_NOTICE_DATE, TD_ID_NAME, TD_CANCEL_DATE, TD_NOTE, TD_STATUS, TD_UPDATE, TD_UPDATE_USER)
			OUTPUT inserted.TD_ID INTO @TBL
			SELECT TD_ID, TD_ID_CLIENT, TD_NOTICE_NUM, TD_NOTICE_DATE, TD_ID_NAME, TD_CANCEL_DATE, TD_NOTE, 2, TD_UPDATE, TD_UPDATE_USER
			FROM Purchase.Tender
			WHERE TD_ID = @ID

		SELECT @NEWID = ID FROM @TBL

		INSERT INTO Purchase.TenderCity(TCT_ID_TENDER, TCT_ID_CITY)
			SELECT @NEWID, TCT_ID_CITY
			FROM Purchase.TenderCity
			WHERE TCT_ID_TENDER = @ID

		INSERT INTO Purchase.TenderClient(TCL_ID_TENDER, TCL_NAME, TCL_PLACE, TCL_ADDRESS, TCL_EMAIL, TCL_RES, TCL_PHONE, TCL_FAX)
			SELECT @NEWID, TCL_NAME, TCL_PLACE, TCL_ADDRESS, TCL_EMAIL, TCL_RES, TCL_PHONE, TCL_FAX
			FROM Purchase.TenderClient
			WHERE TCL_ID_TENDER = @ID

		INSERT INTO Purchase.TenderConditions(TC_ID_TENDER, TC_START_PRICE, TC_CLAIM_SIZE, TC_CLAIM_SIZE_VALUE, TC_CONTRACT_SIZE, TC_CONTRACT_SIZE_VALUE, TC_DELIVERY_BEGIN, TC_DELIVERY_BEGIN_NOTE, TC_DELIVERY_END, TC_DELIVERY_END_NOTE, TC_ID_PAY_PERIOD)
			SELECT @NEWID, TC_START_PRICE, TC_CLAIM_SIZE, TC_CLAIM_SIZE_VALUE, TC_CONTRACT_SIZE, TC_CONTRACT_SIZE_VALUE, TC_DELIVERY_BEGIN, TC_DELIVERY_BEGIN_NOTE, TC_DELIVERY_END, TC_DELIVERY_END_NOTE, TC_ID_PAY_PERIOD
			FROM Purchase.TenderConditions
			WHERE TC_ID_TENDER = @ID

		INSERT INTO Purchase.TenderDocument(TDC_ID_TENDER, TDC_ID_DC)
			SELECT @NEWID, TDC_ID_DC
			FROM Purchase.TenderDocument
			WHERE TDC_ID_TENDER = @ID

		INSERT INTO Purchase.TenderInfo(TI_ID_TENDER, TI_CLAIM_START, TI_CLAIM_END, TI_CLAIM_EL_END, TI_INSPECT_DATE, TI_EL_DATE, TI_ID_SIGN_PERIOD)
			SELECT @NEWID, TI_CLAIM_START, TI_CLAIM_END, TI_CLAIM_EL_END, TI_INSPECT_DATE, TI_EL_DATE, TI_ID_SIGN_PERIOD
			FROM Purchase.TenderInfo
			WHERE TI_ID_TENDER = @ID

		INSERT INTO Purchase.TenderPriceValidation(TPV_ID_TENDER, TPV_ID_PV)
			SELECT @NEWID, TPV_ID_PV
			FROM Purchase.TenderPriceValidation
			WHERE TPV_ID_TENDER = @ID

		INSERT INTO Purchase.TenderPurchaseKind(TPK_ID_TENDER, TPK_ID_PK)
			SELECT @NEWID, TPK_ID_PK
			FROM Purchase.TenderPurchaseKind
			WHERE TPK_ID_TENDER = @ID

		INSERT INTO Purchase.TenderSignPeriod(TSP_ID_TENDER, TSP_ID_SP)
			SELECT @NEWID, TSP_ID_SP
			FROM Purchase.TenderSignPeriod
			WHERE TSP_ID_TENDER = @ID

		INSERT INTO Purchase.TenderTradeSite(TTS_ID_TENDER, TTS_ID_TS)
			SELECT @NEWID, TTS_ID_TS
			FROM Purchase.TenderTradeSite
			WHERE TTS_ID_TENDER = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
