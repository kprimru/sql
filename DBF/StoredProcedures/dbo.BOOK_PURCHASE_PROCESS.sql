USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BOOK_PURCHASE_PROCESS]
	@insid	INT
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

		DECLARE @DT	SMALLDATETIME

		SELECT @DT = INS_DATE
		FROM dbo.InvoiceSaleTable
		WHERE INS_ID = @insid

		IF @DT >= '20150101' AND @DT <= '20150331'
			RETURN

		IF EXISTS
			(
				SELECT *
				FROM dbo.BookPurchase
				WHERE ID_INVOICE = @insid
			)
		BEGIN
			DELETE
			FROM dbo.BookPurchaseDetail
			WHERE ID_PURCHASE IN (SELECT ID FROM dbo.BookPurchase WHERE ID_INVOICE = @insid)

			DELETE FROM dbo.BookPurchase
			WHERE ID_INVOICE = @insid
		END

		DECLARE @ID INT
		DECLARE @PSEDO VARCHAR(20)
		DECLARE @DATE SMALLDATETIME
		DECLARE @CL_ID	INT

		DECLARE @INVOICE_NULL INT

		SELECT @INVOICE_NULL = INS_ID
		FROM dbo.InvoiceSaleTable
		WHERE INS_NUM = 0 AND INS_NUM_YEAR = 0

		SELECT @PSEDO = INT_PSEDO, @ID = INS_ID, @DATE = INS_DATE, @CL_ID = INS_ID_CLIENT
		FROM
			dbo.InvoiceSaleTable
			INNER JOIN dbo.InvoiceTypeTable ON INT_ID = INS_ID_TYPE
		WHERE INS_ID = @insid

		IF @PSEDO = 'ACT'
		BEGIN

			INSERT INTO dbo.BookPurchase(ID_ORG, ID_AVANS, ID_INVOICE, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE, PURCHASE_DATE)
				SELECT DISTINCT INS_ID_ORG, d.INS_ID, @ID, '22', INS_NUM, d.INS_DATE, INS_CLIENT_NAME, INS_CLIENT_INN, INS_CLIENT_KPP, MAX(IN_PAY_NUM), MAX(IN_DATE), a.INS_DATE
				FROM
					(
						SELECT DISTINCT INR_ID_DISTR, INR_ID_PERIOD, INS_DATE
						FROM
							dbo.InvoiceSaleTable z
							INNER JOIN dbo.InvoiceRowTable y ON INR_ID_INVOICE = INS_ID
							INNER JOIN dbo.ActDistrTable x ON AD_ID_DISTR = INR_ID_DISTR AND AD_ID_PERIOD = INR_ID_PERIOD
							INNER JOIN dbo.ActSaldoView w ON w.AD_ID_DISTR = x.AD_ID_DISTR AND x.AD_ID_ACT = ACT_ID
						WHERE INR_ID_INVOICE = @ID AND DELTA IS NOT NULL AND INS_ID_CLIENT = @CL_ID
					) AS a
					INNER JOIN dbo.IncomeDistrTable b ON b.ID_ID_DISTR = a.INR_ID_DISTR AND b.ID_ID_PERIOD = a.INR_ID_PERIOD
					INNER JOIN dbo.IncomeTable c ON c.IN_ID = ID_ID_INCOME
					INNER JOIN dbo.InvoiceSaleTable d ON d.INS_ID = c.IN_ID_INVOICE
				WHERE (d.INS_ID <> @INVOICE_NULL OR @INVOICE_NULL IS NULL) AND INS_ID_CLIENT = @CL_ID AND IN_ID_CLIENT = @CL_ID
				GROUP BY INS_ID_ORG, d.INS_ID, INS_NUM, d.INS_DATE, INS_CLIENT_NAME, INS_CLIENT_INN, INS_CLIENT_KPP, a.INS_DATE

			INSERT INTO dbo.BookPurchaseDetail(ID_PURCHASE, ID_TAX, S_ALL, S_NDS, S_BEZ_NDS)
				SELECT
					(
						SELECT ID
						FROM dbo.BookPurchase z
						WHERE z.ID_AVANS = t.ID_AVANS
							AND z.ID_INVOICE = t.ID_INVOICE
					), TX_ID,
					S_ALL, S_NDS, S_BEZ_NDS
				FROM
					(
						SELECT DISTINCT d.INS_ID AS ID_AVANS, @ID AS ID_INVOICE, d.INS_DATE AS AVANS_DATE
						FROM
							(
								SELECT DISTINCT INR_ID_DISTR, INR_ID_PERIOD, INS_DATE
								FROM
									dbo.InvoiceSaleTable z
									INNER JOIN dbo.InvoiceRowTable y ON INR_ID_INVOICE = INS_ID
									INNER JOIN dbo.ActDistrTable x ON AD_ID_DISTR = INR_ID_DISTR AND AD_ID_PERIOD = INR_ID_PERIOD
									INNER JOIN dbo.ActSaldoView w ON w.AD_ID_DISTR = x.AD_ID_DISTR AND x.AD_ID_ACT = ACT_ID
								WHERE	INR_ID_INVOICE = @ID
									AND DELTA IS NOT NULL
									AND INS_ID_CLIENT = @CL_ID
							) AS a
							INNER JOIN dbo.IncomeDistrTable b ON b.ID_ID_DISTR = a.INR_ID_DISTR AND b.ID_ID_PERIOD = a.INR_ID_PERIOD
							INNER JOIN dbo.IncomeTable c ON c.IN_ID = ID_ID_INCOME
							INNER JOIN dbo.InvoiceSaleTable d ON d.INS_ID = c.IN_ID_INVOICE
						WHERE	ID_PRICE > 0
							AND (d.INS_ID <> @INVOICE_NULL OR @INVOICE_NULL IS NULL)
							AND d.INS_ID_CLIENT = @CL_ID
							AND IN_ID_CLIENT = @CL_ID
					) AS t
					CROSS APPLY
					(
						SELECT
							TX_ID, TX_PERCENT,
							SUM(ID_PRICE) AS S_ALL,
							SUM(ROUND(ID_PRICE - (ID_PRICE / ((100 + TX_PERCENT)/100)), 2)) AS S_NDS,
							SUM(ROUND((ID_PRICE / ((100 + TX_PERCENT)/100)), 2)) AS S_BEZ_NDS
						FROM
							(
								SELECT
									TX_ID, TX_PERCENT,
									b.ID_PRICE - DELTA AS ID_PRICE
								FROM
									dbo.InvoiceRowTable a
									INNER JOIN dbo.IncomeDistrTable b ON a.INR_ID_DISTR = b.ID_ID_DISTR AND INR_ID_PERIOD = ID_ID_PERIOD
									INNER JOIN dbo.IncomeTable c ON c.IN_ID = ID_ID_INCOME
									--INNER JOIN dbo.TaxTable ON INR_ID_TAX = TX_ID
									CROSS APPLY
									(
										SELECT TX_ID, TX_PERCENT
										FROM dbo.TaxTable
										WHERE	INR_ID_TAX = TX_ID
											AND
											(
												DatePart(Year, AVANS_DATE) = DatePart(Year, @DATE)
												OR
												DatePart(Year, AVANS_DATE) != 2018 AND DatePart(Year, @Date) != 2019
											)

										UNION ALL

										SELECT TX_ID, TX_PERCENT
										FROM dbo.TaxTable
										WHERE TX_PERCENT = 18
											AND DatePart(Year, AVANS_DATE) IN (2017, 2018) AND DatePart(Year, @Date) = 2019
									) p
									INNER JOIN dbo.IncomeSaldoView e ON e.ID_ID = b.ID_ID
								WHERE a.INR_ID_INVOICE = t.ID_INVOICE
									AND c.IN_ID_INVOICE = t.ID_AVANS
									AND DELTA IS NOT NULL
									AND c.IN_ID_CLIENT = @CL_ID
							) AS o_O
						GROUP BY TX_ID, TX_PERCENT
					)AS p
		END
		ELSE IF @PSEDO = 'CONSIGNMENT'
		BEGIN
			INSERT INTO dbo.BookPurchase(ID_ORG, ID_AVANS, ID_INVOICE, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE, PURCHASE_DATE)
				SELECT DISTINCT INS_ID_ORG, d.INS_ID, @ID, '22', INS_NUM, d.INS_DATE, INS_CLIENT_NAME, INS_CLIENT_INN, INS_CLIENT_KPP, IN_PAY_NUM, IN_DATE, a.INS_DATE
				FROM
					(
						SELECT DISTINCT INR_ID_DISTR, INR_ID_PERIOD, INS_DATE
						FROM
							dbo.InvoiceSaleTable
							INNER JOIN dbo.InvoiceRowTable ON INR_ID_INVOICE = INS_ID
						WHERE INR_ID_INVOICE = @ID AND INS_ID_CLIENT = @CL_ID
					) AS a
					INNER JOIN dbo.IncomeDistrTable b ON b.ID_ID_DISTR = a.INR_ID_DISTR AND b.ID_ID_PERIOD = a.INR_ID_PERIOD
					INNER JOIN dbo.IncomeTable c ON c.IN_ID = ID_ID_INCOME
					INNER JOIN dbo.InvoiceSaleTable d ON d.INS_ID = c.IN_ID_INVOICE
				WHERE c.IN_ID_CLIENT = @CL_ID AND d.INS_ID_CLIENT = @CL_ID

			INSERT INTO dbo.BookPurchaseDetail(ID_PURCHASE, ID_TAX, S_ALL, S_NDS, S_BEZ_NDS)
				SELECT
					(
						SELECT ID
						FROM dbo.BookPurchase z
						WHERE z.ID_AVANS = t.ID_AVANS
							AND z.ID_INVOICE = t.ID_INVOICE
					), TX_ID,
					ID_PRICE AS S_ALL, ID_PRICE - (ID_PRICE / ((100 + TX_PERCENT)/100)) AS S_NDS,
					(ID_PRICE / ((100 + TX_PERCENT)/100)) AS S_BEZ_NDS
				FROM
					(
						SELECT DISTINCT d.INS_ID AS ID_AVANS, @ID AS ID_INVOICE--, INR_ID_PERIOD, INR_ID_DISTR
						FROM
							(
								SELECT DISTINCT INR_ID_DISTR, INR_ID_PERIOD, INS_DATE
								FROM
									dbo.InvoiceSaleTable z
									INNER JOIN dbo.InvoiceRowTable y ON INR_ID_INVOICE = INS_ID
									INNER JOIN dbo.ConsignmentDetailTable x ON CSD_ID_DISTR = INR_ID_DISTR AND CSD_ID_PERIOD = INR_ID_PERIOD
									--INNER JOIN dbo.ActSaldoView w ON w.AD_ID_DISTR = x.AD_ID_DISTR AND x.AD_ID_ACT = ACT_ID
								WHERE INR_ID_INVOICE = @ID AND INS_ID_CLIENT = @CL_ID
							) AS a
							INNER JOIN dbo.IncomeDistrTable b ON b.ID_ID_DISTR = a.INR_ID_DISTR AND b.ID_ID_PERIOD = a.INR_ID_PERIOD
							INNER JOIN dbo.IncomeTable c ON c.IN_ID = ID_ID_INCOME
							INNER JOIN dbo.InvoiceSaleTable d ON d.INS_ID = c.IN_ID_INVOICE
						WHERE ID_PRICE > 0 AND (d.INS_ID <> @INVOICE_NULL OR @INVOICE_NULL IS NULL)
							AND d.INS_ID_CLIENT = @CL_ID AND IN_ID_CLIENT = @CL_ID
					) AS t
					CROSS APPLY
					(
						SELECT
							TX_ID, TX_PERCENT,
							SUM(b.ID_PRICE - DELTA) AS ID_PRICE
						FROM
							dbo.InvoiceRowTable a
							INNER JOIN dbo.IncomeDistrTable b ON a.INR_ID_DISTR = b.ID_ID_DISTR AND INR_ID_PERIOD = ID_ID_PERIOD
							INNER JOIN dbo.IncomeTable c ON c.IN_ID = ID_ID_INCOME
							--INNER JOIN dbo.DistrView d ON DIS_ID = ID_ID_DISTR
							--INNER JOIN dbo.SaleObjectTable ON SO_ID = SYS_ID_SO
							--INNER JOIN dbo.TaxTable ON SO_ID_TAX = TX_ID
							INNER JOIN dbo.TaxTable ON INR_ID_TAX = TX_ID
							INNER JOIN dbo.IncomeSaldoView e ON e.ID_ID = b.ID_ID
						WHERE a.INR_ID_INVOICE = t.ID_INVOICE AND c.IN_ID_INVOICE = t.ID_AVANS AND DELTA IS NOT NULL
							AND c.IN_ID_CLIENT = @CL_ID
						GROUP BY TX_ID, TX_PERCENT
					)AS p
		END
		ELSE IF @PSEDO = 'PRIMARY'
		BEGIN
			INSERT INTO dbo.BookPurchase(ID_ORG, ID_AVANS, ID_INVOICE, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE, PURCHASE_DATE)
				SELECT TOP 1 INS_ID_ORG, a.INS_ID, @ID, '22', INS_NUM, a.INS_DATE, INS_CLIENT_NAME, INS_CLIENT_INN, INS_CLIENT_KPP, NULL, NULL, @DATE
				FROM
					dbo.InvoiceSaleTable a
					INNER JOIN dbo.InvoiceTypeTable b ON a.INS_ID_TYPE = b.INT_ID
				WHERE b.INT_PSEDO = 'INCOME'
					AND a.INS_DATE <= @DATE
					AND a.INS_ID_CLIENT = @CL_ID
					AND EXISTS
						(
							SELECT *
							FROM dbo.InvoiceRowTable
							WHERE INR_ID_PERIOD IS NULL
								AND INR_ID_INVOICE = INS_ID
						)
				ORDER BY INS_DATE DESC


			INSERT INTO dbo.BookPurchaseDetail(ID_PURCHASE, ID_TAX, S_ALL, S_NDS, S_BEZ_NDS)
				SELECT
					(
						SELECT ID
						FROM dbo.BookPurchase z
						WHERE z.ID_AVANS = t.INS_ID
							AND z.ID_INVOICE = @ID
					), INR_ID_TAX,
					S_ALL, S_NDS, S_BEZ_NDS
				FROM
					(
						SELECT TOP 1 INS_ID
						FROM
							dbo.InvoiceSaleTable a
							INNER JOIN dbo.InvoiceTypeTable b ON a.INS_ID_TYPE = b.INT_ID
						WHERE b.INT_PSEDO = 'INCOME'
							AND a.INS_DATE <= @DATE
							AND a.INS_ID_CLIENT = @CL_ID
							AND EXISTS
								(
									SELECT *
									FROM dbo.InvoiceRowTable
									WHERE INR_ID_PERIOD IS NULL
										AND INR_ID_INVOICE = INS_ID
								)
						ORDER BY INS_DATE DESC
					) AS t
					CROSS APPLY
					(
						SELECT
							INR_ID_TAX, SUM(INR_SUM * ISNULL(INR_COUNT, 1)) AS S_BEZ_NDS,
							SUM(INR_SNDS) AS S_NDS, SUM(INR_SALL) AS S_ALL
						FROM
							dbo.InvoiceRowTable a
						WHERE a.INR_ID_INVOICE = CASE WHEN (SELECT SUM(INR_SALL) FROM dbo.InvoiceRowTable WHERE INR_ID_INVOICE = @ID) <= (SELECT SUM(INR_SALL) FROM dbo.InvoiceRowTable WHERE INR_ID_INVOICE = INS_ID) THEN @ID ELSE INS_ID END
						GROUP BY INR_ID_TAX
					)AS p
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
