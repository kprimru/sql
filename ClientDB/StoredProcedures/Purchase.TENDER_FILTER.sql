USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[TENDER_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[TENDER_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[TENDER_FILTER]
	@DATE_BEGIN		SMALLDATETIME,
	@DATE_END		SMALLDATETIME,
	@PURCHASE_TYPE	UNIQUEIDENTIFIER,
	@TRADE_SITE		UNIQUEIDENTIFIER,
	@STATUS			INT,
	@PRICE_BEGIN	MONEY,
	@PRICE_END		MONEY,
	@CLIENT			VARCHAR(100)
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
			TD_ID, TD_NOTICE_NUM, TD_NOTICE_DATE, TN_NAME, ClientID, ClientFullName,
			REVERSE(STUFF(REVERSE(
				(
					SELECT TS_NAME + ', '
					FROM
						Purchase.TenderTradeSite
						INNER JOIN Purchase.TradeSite ON TS_ID = TTS_ID_TS
					WHERE TTS_ID_TENDER = TN_ID
					ORDER BY TS_NAME FOR XML PATH('')
				)
			), 1, 2, '')) AS TD_TRADE_SITE,
			REVERSE(STUFF(REVERSE(
				(
					SELECT PK_NAME + ', '
					FROM
						Purchase.TenderPurchaseKind
						INNER JOIN Purchase.PurchaseKind ON PK_ID = TPK_ID_PK
					WHERE TPK_ID_TENDER = TN_ID
					ORDER BY PK_NAME FOR XML PATH('')
				)
			), 1, 2, '')) AS TD_PURCHASE_KIND,
			TC_START_PRICE,
			CONVERT(VARCHAR(20), TD_UPDATE, 104) + ' ' + CONVERT(VARCHAR(20), TD_UPDATE, 108) + ' / ' + TD_UPDATE_USER AS TD_UPDATE_DATA
		FROM
			Purchase.Tender
			INNER JOIN Purchase.TenderConditions ON TD_ID = TC_ID_TENDER
			INNER JOIN dbo.ClientTable ON ClientID = TD_ID_CLIENT
			INNER JOIN Purchase.TenderName ON TN_ID = TD_ID_NAME
		WHERE TD_STATUS = 1
			AND (TD_NOTICE_DATE >= @DATE_BEGIN OR @DATE_BEGIN IS NULL)
			AND (TD_NOTICE_DATE <= @DATE_END OR @DATE_END IS NULL)
			AND
				(
					@PURCHASE_TYPE IS NULL OR
					EXISTS
						(
							SELECT *
							FROM Purchase.TenderPurchaseKind
							WHERE TPK_ID_TENDER = TD_ID AND TPK_ID_PK = @PURCHASE_TYPE
						)
				)
			AND
				(
					@TRADE_SITE IS NULL OR
					EXISTS
						(
							SELECT *
							FROM Purchase.TenderTradeSite
							WHERE TTS_ID_TENDER = TD_ID AND TTS_ID_TS = @TRADE_SITE
						)
				)
			AND (StatusID = @STATUS OR @STATUS IS NULL)
			AND (TC_START_PRICE >= @PRICE_BEGIN OR @PRICE_BEGIN IS NULL)
			AND (TC_START_PRICE < @PRICE_END OR @PRICE_END IS NULL)
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
		ORDER BY TD_NOTICE_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[TENDER_FILTER] TO rl_filter_tender;
GO
