USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BOOK_PURCHASE_1C]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ORG	INT
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

		DELETE a
		FROM dbo.BookPurchase a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.BookPurchaseDetail b
				WHERE a.ID = b.ID_PURCHASE
			)

		DELETE
		FROM dbo.BookPurchase
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.InvoiceSaleTable
				WHERE ID_INVOICE = INS_ID
			)
			OR
			NOT EXISTS
			(
				SELECT *
				FROM dbo.InvoiceSaleTable
				WHERE ID_AVANS = INS_ID
			)

		UPDATE dbo.GlobalSettingsTable
		SET GS_VALUE = CONVERT(VARCHAR(20), @begin, 104)
		WHERE GS_NAME = 'BOOK_START'

		UPDATE dbo.GlobalSettingsTable
		SET GS_VALUE = CONVERT(VARCHAR(20), @end, 104)
		WHERE GS_NAME = 'BOOK_FINISH'

		SELECT
			ROW_NUMBER() OVER(ORDER BY DATE, NUM) AS RN,
			CODE, NUM, DATE, INS_ID_CLIENT AS CL_ID,
			ORG_SHORT_NAME AS NAME,
			--INS_CLIENT_NAME AS NAME,
			ORG_INN AS INN, ORG_KPP AS KPP, ORG_INN + '/' + ORG_KPP AS INN_KPP,
			/*NAME,
			INN, KPP,
			CASE
				WHEN ISNULL(INN, '') <> '' AND ISNULL(KPP, '') <> '' THEN INN + '/' + KPP
				WHEN ISNULL(INN, '') <> '' AND ISNULL(KPP, '') = '' THEN INN
				ELSE ''
			END AS INN_KPP,*/

			LEFT(IN_NUM, 6) AS IN_NUM, IN_DATE,
			CASE
				WHEN PURCHASE_DATE IS NOT NULL THEN NULL
				WHEN IN_DATE IS NOT NULL THEN CONVERT(VARCHAR(20), IN_NUM) + ' ' + CONVERT(VARCHAR(20), IN_DATE, 104)
				ELSE ''
			END AS IN_STR,
			(
				SELECT SUM(S_ALL)
				FROM dbo.BookPurchaseDetail b
				WHERE b.ID_PURCHASE = a.ID
			) AS INS_SUM,
			(
				SELECT SUM(S_NDS)
				FROM dbo.BookPurchaseDetail b
				WHERE b.ID_PURCHASE = a.ID
					--AND ID_TAX = 1
			) AS INS_NDS,
			PURCHASE_DATE AS ACT_DATE
		FROM
			dbo.BookPurchase a
			INNER JOIN dbo.InvoiceSaleTable ON INS_ID = ID_INVOICE
			INNER JOIN dbo.OrganizationTable ON a.ID_ORG = ORG_ID
		WHERE ID_ORG = @ORG AND ISNULL(PURCHASE_DATE, IN_DATE) BETWEEN @BEGIN AND @END
		ORDER BY DATE, NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[BOOK_PURCHASE_1C] TO rl_book_buy_p;
GO
