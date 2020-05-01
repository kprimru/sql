USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Purchase].[TENDER_PRINT]
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

		SELECT
			TD_NOTICE_NUM, TD_NOTICE_DATE, TN_NAME,
			REVERSE(STUFF(REVERSE(
				(
					SELECT PK_NAME + CHAR(10)
					FROM
						Purchase.TenderPurchaseKind
						INNER JOIN Purchase.PurchaseKind ON PK_ID = TPK_ID_PK
					WHERE TPK_ID_TENDER = TD_ID
					ORDER BY PK_NAME FOR XML PATH('')
				)
			), 1, 1, '')) AS TD_PURHCASE_KIND,
			REVERSE(STUFF(REVERSE(
				(
					SELECT TS_NAME + CHAR(10)
					FROM
						Purchase.TenderTradeSite
						INNER JOIN Purchase.TradeSite ON TS_ID = TTS_ID_TS
					WHERE TTS_ID_TENDER = TD_ID
					ORDER BY TS_NAME FOR XML PATH('')
				)
			), 1, 1, '')) AS TD_TRADE_SITE,
			TCL_NAME, TCL_PLACE, TCL_ADDRESS, TCL_EMAIL, TCL_RES, TCL_PHONE, TCL_FAX,
			TC_START_PRICE,
			TC_CLAIM_SIZE, TC_CLAIM_SIZE_VALUE,
			TC_CONTRACT_SIZE, TC_CONTRACT_SIZE_VALUE,
			'с ' + ISNULL(CONVERT(VARCHAR(20), TC_DELIVERY_BEGIN, 104), ' ') + TC_DELIVERY_BEGIN_NOTE + ' по ' + ISNULL(CONVERT(VARCHAR(20), TC_DELIVERY_END, 104), ' ') + TC_DELIVERY_END_NOTE AS TC_DELIVERY,
			PP_NAME,
			REVERSE(STUFF(REVERSE(
				(
					SELECT PV_NAME + CHAR(10)
					FROM
						Purchase.TenderPriceValidation
						INNER JOIN Purchase.PriceValidation ON PV_ID = TPV_ID_PV
					WHERE TPV_ID_TENDER = TD_ID
					ORDER BY PV_NAME FOR XML PATH('')
				)
			), 1, 1, '')) AS TD_PRICE_VALIDATE,
			REVERSE(STUFF(REVERSE(
				(
					SELECT CT_NAME + CHAR(10)
					FROM
						Purchase.TenderCity
						INNER JOIN dbo.City ON CT_ID = TCT_ID_CITY
					WHERE TCT_ID_TENDER = TD_ID
					ORDER BY CT_NAME FOR XML PATH('')
				)
			), 1, 1, '')) AS TD_CITY,
			REVERSE(STUFF(REVERSE(
				(
					SELECT DC_NAME + CHAR(10)
					FROM
						Purchase.TenderDocument
						INNER JOIN Purchase.Document ON DC_ID = TDC_ID_DC
					WHERE TDC_ID_TENDER = TD_ID
					ORDER BY DC_NAME FOR XML PATH('')
				)
			), 1, 1, '')) AS TD_DOCUMENT,
			TI_CLAIM_START, TI_CLAIM_END, TI_CLAIM_EL_END, TI_INSPECT_DATE, TI_EL_DATE,
			SP_NAME
		FROM
			Purchase.Tender
			INNER JOIN Purchase.TenderName ON TN_ID = TD_ID_NAME
			INNER JOIN Purchase.TenderClient ON TCL_ID_TENDER = TD_ID
			INNER JOIN Purchase.TenderConditions ON TC_ID_TENDER = TD_ID
			INNER JOIN Purchase.PayPeriod ON TC_ID_PAY_PERIOD = PP_ID
			INNER JOIN Purchase.TenderInfo ON TI_ID_TENDER = TD_ID
			INNER JOIN Purchase.SignPeriod ON SP_ID = TI_ID_SIGN_PERIOD
		WHERE TD_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Purchase].[TENDER_PRINT] TO rl_tender_r;
GO