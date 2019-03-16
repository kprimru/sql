USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[BOOK_SALE_1C]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ORG	INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE a
	FROM dbo.BookSale a
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.BookSaleDetail b 
			WHERE a.ID = b.ID_SALE
		)

	DELETE
	FROM dbo.BookSale
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.InvoiceSaleTable
			WHERE ID_INVOICE = INS_ID
		)

	UPDATE dbo.GlobalSettingsTable
	SET GS_VALUE = CONVERT(VARCHAR(20), @begin, 104)
	WHERE GS_NAME = 'BOOK_START'
	
	UPDATE dbo.GlobalSettingsTable
	SET GS_VALUE = CONVERT(VARCHAR(20), @end, 104)
	WHERE GS_NAME = 'BOOK_FINISH'

	SELECT
		RN, CODE, NUM, DATE, CL_ID, NAME, INN, KPP, INN_KPP, IN_NUM, IN_DATE, IN_STR,
		INS_SUM, 
		INS_20_SUM, 
		CASE 
			--WHEN NUM IN (2297, 4774, 7194) THEN NULL
			WHEN NUM IN (0) THEN NULL
			ELSE
				CASE CODE 			
					WHEN '02' THEN NULL 
					WHEN '06' THEN NULL 
					ELSE INS_20_PRICE 
				END 
		END AS INS_20_PRICE, 
		INS_20_NDS, 
		INS_18_SUM, 
		CASE 
			--WHEN NUM IN (2297, 4774, 7194) THEN NULL
			WHEN NUM IN (0) THEN NULL
			ELSE
				CASE CODE 			
					WHEN '02' THEN NULL 
					WHEN '06' THEN NULL 
					ELSE INS_18_PRICE 
				END 
		END AS INS_18_PRICE, 
		INS_18_NDS, 
		INS_10_SUM, 
		CASE CODE 
			WHEN '02' THEN NULL 
			WHEN '06' THEN NULL 
			ELSE INS_10_PRICE 
		END AS INS_10_PRICE, INS_10_NDS, 
		CASE CODE 
			WHEN '02' THEN NULL 
			WHEN '06' THEN NULL 
			ELSE INS_0_SUM 
		END AS INS_0_SUM
	FROM
		(
			SELECT 
				ROW_NUMBER() OVER(ORDER BY DATE, NUM) AS RN,
				CODE, NUM, DATE, INS_ID_CLIENT AS CL_ID, NAME, INN, KPP, 
				CASE 
					WHEN ISNULL(INN, '') <> '' AND ISNULL(KPP, '') <> '' THEN INN + '/' + KPP
					WHEN ISNULL(INN, '') <> '' AND ISNULL(KPP, '') = '' THEN INN
					ELSE ''
				END AS INN_KPP,
				LEFT(IN_NUM, 6) AS IN_NUM, IN_DATE,
				CASE 
					WHEN IN_DATE IS NOT NULL THEN CONVERT(VARCHAR(20), IN_NUM) + ' от ' + CONVERT(VARCHAR(20), IN_DATE, 104)
					ELSE ''
				END AS IN_STR,
				(
					SELECT SUM(S_ALL)
					FROM dbo.BookSaleDetail b
					WHERE b.ID_SALE = a.ID 
				) AS INS_SUM,
				(
					SELECT SUM(S_ALL)
					FROM 
						dbo.BookSaleDetail b
						INNER JOIN dbo.TaxTable ON ID_TAX = TX_ID
					WHERE b.ID_SALE = a.ID AND TX_PERCENT = 20
				) AS INS_20_SUM,
				(
					SELECT SUM(S_BEZ_NDS)
					FROM 
						dbo.BookSaleDetail b
						INNER JOIN dbo.TaxTable ON ID_TAX = TX_ID
					WHERE b.ID_SALE = a.ID AND TX_PERCENT = 20
				) AS INS_20_PRICE,
				(
					SELECT SUM(S_NDS)
					FROM 
						dbo.BookSaleDetail b
						INNER JOIN dbo.TaxTable ON ID_TAX = TX_ID
					WHERE b.ID_SALE = a.ID AND TX_PERCENT = 20
				) AS INS_20_NDS,
				(
					SELECT SUM(S_ALL)
					FROM 
						dbo.BookSaleDetail b
						INNER JOIN dbo.TaxTable ON ID_TAX = TX_ID
					WHERE b.ID_SALE = a.ID AND TX_PERCENT = 18
				) AS INS_18_SUM,
				(
					SELECT SUM(S_BEZ_NDS)
					FROM 
						dbo.BookSaleDetail b
						INNER JOIN dbo.TaxTable ON ID_TAX = TX_ID
					WHERE b.ID_SALE = a.ID AND TX_PERCENT = 18
				) AS INS_18_PRICE,
				(
					SELECT SUM(S_NDS)
					FROM 
						dbo.BookSaleDetail b
						INNER JOIN dbo.TaxTable ON ID_TAX = TX_ID
					WHERE b.ID_SALE = a.ID AND TX_PERCENT = 18
				) AS INS_18_NDS,
				(
					SELECT SUM(S_ALL)
					FROM 
						dbo.BookSaleDetail b
						INNER JOIN dbo.TaxTable ON ID_TAX = TX_ID
					WHERE b.ID_SALE = a.ID AND TX_PERCENT = 10
				) AS INS_10_SUM,
				(
					SELECT SUM(S_BEZ_NDS)
					FROM 
						dbo.BookSaleDetail b
						INNER JOIN dbo.TaxTable ON ID_TAX = TX_ID
					WHERE b.ID_SALE = a.ID AND TX_PERCENT = 10
				) AS INS_10_PRICE,
				(
					SELECT SUM(S_NDS)
					FROM 
						dbo.BookSaleDetail b
						INNER JOIN dbo.TaxTable ON ID_TAX = TX_ID
					WHERE b.ID_SALE = a.ID AND TX_PERCENT = 10
				) AS INS_10_NDS,
				(
					SELECT SUM(S_ALL)
					FROM 
						dbo.BookSaleDetail b
						INNER JOIN dbo.TaxTable ON ID_TAX = TX_ID
					WHERE b.ID_SALE = a.ID AND TX_PERCENT = 0
				) AS INS_0_SUM
			FROM 
				dbo.BookSale a
				INNER JOIN dbo.InvoiceSaleTable ON INS_ID = ID_INVOICE
			WHERE ID_ORG = @ORG AND DATE BETWEEN @BEGIN AND @END --AND CODE = '01'
		) AS o_O
	ORDER BY DATE, NUM
END
