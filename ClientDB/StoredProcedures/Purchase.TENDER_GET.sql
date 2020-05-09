USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Purchase].[TENDER_GET]
	@ID	UNIQUEIDENTIFIER,
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF @ID IS NULL
		BEGIN
			SELECT
				TD_NOTICE_NUM, TD_NOTICE_DATE,
				TD_ID_NAME, TD_CANCEL_DATE, TD_NOTE,

				ClientFullName AS TCL_NAME, CONVERT(VARCHAR(250), '') AS TCL_PLACE, CA_STR AS TCL_ADDRESS,
				ClientEmail AS TCL_EMAIL, CP_FIO AS TCL_RES, CP_PHONE AS TCL_PHONE, CONVERT(VARCHAR(250), '') AS TCL_FAX,

				TC_START_PRICE,
				TC_CLAIM_SIZE, TC_CLAIM_SIZE_VALUE,
				TC_CONTRACT_SIZE, TC_CONTRACT_SIZE_VALUE,
				TC_DELIVERY_BEGIN, TC_DELIVERY_BEGIN_NOTE,
				TC_DELIVERY_END, TC_DELIVERY_END_NOTE, 
				PP_ID,

				TI_CLAIM_START, TI_CLAIM_END, TI_CLAIM_EL_END,
				TI_INSPECT_DATE, TI_EL_DATE, TI_ID_SIGN_PERIOD,

				('<LIST>' +
					(
						SELECT '{' + CONVERT(VARCHAR(50), TCT_ID_CITY) + '}' AS ITEM
						FROM Purchase.TenderCity
						WHERE TCT_ID_TENDER = TD_ID
						ORDER BY TCT_ID_CITY FOR XML PATH('')
					)
				+ '</LIST>') AS TD_CITY_ID,
				('<LIST>' +
					(
						SELECT '{' + CONVERT(VARCHAR(50), TDC_ID_DC) + '}' AS ITEM
						FROM Purchase.TenderDocument
						WHERE TDC_ID_TENDER = TD_ID
						ORDER BY TDC_ID_DC FOR XML PATH('')
					)
				+ '</LIST>') AS TD_DOCUMENT_ID,
				('<LIST>' +
					(
						SELECT '{' + CONVERT(VARCHAR(50), TPV_ID_PV) + '}' AS ITEM
						FROM Purchase.TenderPriceValidation
						WHERE TPV_ID_TENDER = TD_ID
						ORDER BY TPV_ID_PV FOR XML PATH('')
					)
				+ '</LIST>') AS TD_PRICE_VALIDATION_ID,
				('<LIST>' +
					(
						SELECT '{' + CONVERT(VARCHAR(50), TPK_ID_PK) + '}' AS ITEM
						FROM Purchase.TenderPurchaseKind
						WHERE TPK_ID_TENDER = TD_ID
						ORDER BY TPK_ID_PK FOR XML PATH('')
					)
				+ '</LIST>') AS TD_PURCHASE_KIND_ID,
				('<LIST>' +
					(
						SELECT '{' + CONVERT(VARCHAR(50), TTS_ID_TS) + '}' AS ITEM
						FROM Purchase.TenderTradeSite
						WHERE TTS_ID_TENDER = TD_ID
						ORDER BY TTS_ID_TS FOR XML PATH('')
					)
				+ '</LIST>') AS TD_TRADE_SITE_ID
			FROM
				dbo.ClientTable
				LEFT OUTER JOIN dbo.ClientAddressView ON CA_ID_CLIENT = ClientID AND AT_REQUIRED = 1
				LEFT OUTER JOIN dbo.ClientPersonalResView WITH(NOEXPAND) ON ClientID = CP_ID_CLIENT
				LEFT OUTER JOIN Purchase.Tender ON TD_ID = @ID
				LEFT OUTER JOIN Purchase.TenderClient ON TCL_ID_TENDER = TD_ID
				LEFT OUTER JOIN Purchase.TenderConditions ON TC_ID_TENDER = TD_ID
				LEFT OUTER JOIN Purchase.PayPeriod ON PP_ID = TC_ID_PAY_PERIOD
				LEFT OUTER JOIN Purchase.TenderInfo ON TI_ID_TENDER = TD_ID
			WHERE ClientID = @CLIENT
		END
		ELSE
		BEGIN
			SELECT
				TD_NOTICE_NUM, TD_NOTICE_DATE,
				TD_ID_NAME, TD_NOTE, TD_CANCEL_DATE,

				TCL_NAME, TCL_PLACE, TCL_ADDRESS,
				TCL_EMAIL, TCL_RES, TCL_PHONE, TCL_FAX,

				TC_START_PRICE,
				TC_CLAIM_SIZE, TC_CLAIM_SIZE_VALUE,
				TC_CONTRACT_SIZE, TC_CONTRACT_SIZE_VALUE,
				TC_DELIVERY_BEGIN, TC_DELIVERY_BEGIN_NOTE,
				TC_DELIVERY_END, TC_DELIVERY_END_NOTE, 
				PP_ID,

				TI_CLAIM_START, TI_CLAIM_END, TI_CLAIM_EL_END,
				TI_INSPECT_DATE, TI_EL_DATE, TI_ID_SIGN_PERIOD,

				('<LIST>' +
					(
						SELECT '{' + CONVERT(VARCHAR(50), TCT_ID_CITY) + '}' AS ITEM
						FROM Purchase.TenderCity
						WHERE TCT_ID_TENDER = TD_ID
						ORDER BY TCT_ID_CITY FOR XML PATH('')
					)
				+ '</LIST>') AS TD_CITY_ID,
				('<LIST>' +
					(
						SELECT '{' + CONVERT(VARCHAR(50), TDC_ID_DC) + '}' AS ITEM
						FROM Purchase.TenderDocument
						WHERE TDC_ID_TENDER = TD_ID
						ORDER BY TDC_ID_DC FOR XML PATH('')
					)
				+ '</LIST>') AS TD_DOCUMENT_ID,
				('<LIST>' +
					(
						SELECT '{' + CONVERT(VARCHAR(50), TPV_ID_PV) + '}' AS ITEM
						FROM Purchase.TenderPriceValidation
						WHERE TPV_ID_TENDER = TD_ID
						ORDER BY TPV_ID_PV FOR XML PATH('')
					)
				+ '</LIST>') AS TD_PRICE_VALIDATION_ID,
				('<LIST>' +
					(
						SELECT '{' + CONVERT(VARCHAR(50), TPK_ID_PK) + '}' AS ITEM
						FROM Purchase.TenderPurchaseKind
						WHERE TPK_ID_TENDER = TD_ID
						ORDER BY TPK_ID_PK FOR XML PATH('')
					)
				+ '</LIST>') AS TD_PURCHASE_KIND_ID,
				('<LIST>' +
					(
						SELECT '{' + CONVERT(VARCHAR(50), TTS_ID_TS) + '}' AS ITEM
						FROM Purchase.TenderTradeSite
						WHERE TTS_ID_TENDER = TD_ID
						ORDER BY TTS_ID_TS FOR XML PATH('')
					)
				+ '</LIST>') AS TD_TRADE_SITE_ID
			FROM
				Purchase.Tender
				INNER JOIN Purchase.TenderClient ON TCL_ID_TENDER = TD_ID
				INNER JOIN Purchase.TenderConditions ON TC_ID_TENDER = TD_ID
				INNER JOIN Purchase.PayPeriod ON PP_ID = TC_ID_PAY_PERIOD
				INNER JOIN Purchase.TenderInfo ON TI_ID_TENDER = TD_ID
			WHERE TD_ID = @ID
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[TENDER_GET] TO rl_tender_r;
GO