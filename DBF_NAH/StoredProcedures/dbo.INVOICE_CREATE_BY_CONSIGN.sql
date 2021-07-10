USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[INVOICE_CREATE_BY_CONSIGN]
	@consignid INT,
	@invdate SMALLDATETIME,
	@reserve BIT,
	@print BIT,
	@insid INT OUTPUT,
	@returndataset BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	-- 1 выбрать мастер-данные для счет-фактуры

	IF NOT EXISTS
			(
				SELECT *
				FROM
					dbo.ConsignmentDetailTable INNER JOIN
					dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = CSD_ID_DISTR INNER JOIN
					dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID
				WHERE CSD_ID_CONS = @consignid
					AND DOC_PSEDO = 'INV_CONSIG'
					AND DD_PRINT = 1
					AND CSD_TOTAL_PRICE <> 0
			)
	BEGIN
		EXEC dbo.INVOICE_PRINT_BY_ID_LIST NULL
	END

	--DECLARE @insid INT

	INSERT INTO dbo.InvoiceSaleTable
					(
						INS_ID_ORG, INS_DATE, INS_NUM, INS_NUM_YEAR, INS_ID_CLIENT,
						INS_CLIENT_NAME, INS_CLIENT_ADDR, INS_CONSIG_NAME, INS_CONSIG_ADDR,
						INS_CLIENT_INN, INS_CLIENT_KPP, INS_DOC_STRING, INS_RESERVE,
						INS_ID_TYPE, INS_ID_PAYER, INS_IDENT
					)
			SELECT
				CSG_ID_ORG, CSG_DATE,
				(
					SELECT ISNULL(MAX(INS_NUM)+1, 1)
					FROM dbo.InvoiceSaleTable
					WHERE INS_NUM_YEAR = RIGHT(DATEPART(yy, @invdate),2)
						AND INS_ID_ORG = CSG_ID_ORG
				),
				RIGHT(DATEPART(yy, @invdate),2),
				CSG_ID_CLIENT,
				CL_FULL_NAME,
				(
					SELECT
						CASE
							WHEN ISNULL(FAT_ID_ADDR_TYPE, '') = '' THEN FAT_TEXT
							ELSE
								(
	/*							SELECT ISNULL(CT_PREFIX+CT_NAME+', '+ST_PREFIX+ST_NAME+', д.'+CA_HOME, CA_STR)
								FROM
									dbo.ClientTable INNER JOIN
									dbo.ClientAddressView a ON CL_ID = CA_ID_CLIENT
								WHERE
									CL_ID = CSG_ID_CLIENT
									AND CA_ID_TYPE = FAT_ID_ADDR_TYPE
	*/
								SELECT
									CASE ADDR_STRING
										WHEN '' THEN CA_STR
										ELSE ADDR_STRING
									END AS ADDR_STRING
								FROM
									dbo.ClientTable					A				INNER JOIN
									dbo.ClientAddressView			B	ON A.CL_ID = B.CA_ID_CLIENT INNER JOIN
									dbo.ClientFinancingAddressView	C	ON A.CL_ID = C.CL_ID
																		AND B.CA_ID_TYPE = C.CA_ID_TYPE
																		AND C.FAT_ID=O_O.FAT_ID
								WHERE
									A.CL_ID = ISNULL(CSG_ID_PAYER, CSG_ID_CLIENT)
									AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
								)
						END
					FROM dbo.FinancingAddressTypeTable AS O_O
					WHERE FAT_DOC = 'INV_CONS_BUY'
				),
				CL_FULL_NAME,
				(
					SELECT
						CASE
							WHEN ISNULL(FAT_ID_ADDR_TYPE, '') = '' THEN FAT_TEXT
							ELSE
								(
	/*							SELECT ISNULL(CT_PREFIX+CT_NAME+', '+ST_PREFIX+ST_NAME+', д.'+CA_HOME, CA_STR)
								FROM
									dbo.ClientTable INNER JOIN
									dbo.ClientAddressView a ON CL_ID = CA_ID_CLIENT
								WHERE
									CL_ID = CSG_ID_CLIENT
									AND CA_ID_TYPE = FAT_ID_ADDR_TYPE
	*/
								SELECT
									CASE ADDR_STRING
										WHEN '' THEN CA_STR
										ELSE ADDR_STRING
									END AS ADDR_STRING
								FROM
									dbo.ClientTable					A				INNER JOIN
									dbo.ClientAddressView			B	ON A.CL_ID = B.CA_ID_CLIENT INNER JOIN
									dbo.ClientFinancingAddressView	C	ON A.CL_ID = C.CL_ID
																		AND B.CA_ID_TYPE = C.CA_ID_TYPE
																		AND C.FAT_ID=O_O.FAT_ID
								WHERE
									A.CL_ID = ISNULL(CSG_ID_PAYER, CSG_ID_CLIENT)
									AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
								)
						END
					FROM dbo.FinancingAddressTypeTable AS O_O
					WHERE FAT_DOC = 'INV_CONS_CONS'
				),
				CL_INN, CL_KPP, CSG_FOUND,
				@reserve,
				(
					SELECT INT_ID
					FROM dbo.InvoiceTypeTable
					WHERE INT_PSEDO = 'CONSIGNMENT'
				), CSG_ID_PAYER,
				(
					SELECT TOP 1 CO_IDENT
					FROM
						dbo.ContractTable
					WHERE
						CO_ID_CLIENT = CL_ID
					ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
				) AS INS_IDENT
			FROM
				dbo.ConsignmentTable LEFT OUTER JOIN
				dbo.ClientTable ON CL_ID = ISNULL(CSG_ID_PAYER, CSG_ID_CLIENT)
			WHERE CSG_ID = @consignid
				AND NOT EXISTS
					(
						SELECT *
						FROM
							dbo.ConsignmentTable LEFT OUTER JOIN
							dbo.InvoiceSaleTable ON CSG_ID_INVOICE = INS_ID
						WHERE CSG_ID = @consignid AND INS_RESERVE = 1
					)


	SELECT @insid = SCOPE_IDENTITY()



	IF @insid IS NULL
		BEGIN
			SELECT @insid = CSG_ID_INVOICE
			FROM dbo.ConsignmentTable
			WHERE CSG_ID = @consignid

			UPDATE dbo.InvoiceSaleTable
			SET INS_RESERVE = 0
			WHERE INS_ID = @insid
		END

	INSERT INTO dbo.InvoiceRowTable
				(
					INR_ID_INVOICE, INR_ID_DISTR, INR_ID_PERIOD,
					INR_GOOD, INR_NAME, INR_SUM, INR_ID_TAX, INR_TNDS,
					INR_SNDS, INR_SALL, INR_PPRICE, INR_UNIT, INR_COUNT
				)
		SELECT
			@insid, CSD_ID_DISTR, CSD_ID_PERIOD, GD_NAME,
			CASE ISNULL(DF_NAME, '') WHEN '' THEN ISNULL(SYS_PREFIX, '') + ' ' + SYS_NAME ELSE DF_NAME END,
			ROUND(CSD_PRICE/2,2), CSD_ID_TAX, TX_PERCENT,
			CSD_TAX_PRICE, CSD_TOTAL_PRICE, CSD_PAYED_PRICE, UN_NAME, CSD_COUNT
		FROM
			dbo.ConsignmentDetailTable INNER JOIN
			dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = CSD_ID_DISTR INNER JOIN
			dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID INNER JOIN
			dbo.SaleObjectTable ON SO_ID = SYS_ID_SO INNER JOIN
			dbo.TaxTable ON SO_ID_TAX = TX_ID LEFT OUTER JOIN
			dbo.DistrFinancingTable ON DF_ID_DISTR = a.DIS_ID
		WHERE CSD_ID_CONS = @consignid AND DOC_PSEDO = 'INV_CONSIG' AND DD_PRINT = 1

	UPDATE dbo.ConsignmentTable
	SET CSG_ID_INVOICE = @insid
	WHERE CSG_ID = @consignid

	UPDATE dbo.InvoiceSaleTable
	SET INS_DOC_STRING =
		(
			SELECT CSG_FOUND
			FROM dbo.ConsignmentTable
			WHERE CSG_ID = @consignid
		)
	WHERE INS_ID = @insid

	SELECT @insid = CSG_ID_INVOICE
	FROM dbo.ConsignmentTable
	WHERE CSG_ID = @consignid

	/*
	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT INS_ID_CLIENT, @insid, 'INVOICE', 'Создание с/ф по накладной', INS_DATA
		FROM dbo.InvoiceProtocolView
		WHERE INS_ID = @insid
	*/

	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Создание с/ф по накладной', '№' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) + ' от ' + CONVERT(VARCHAR(20), INS_DATE, 104)
		FROM
			dbo.InvoiceSaleTable
		WHERE INS_ID = @insid

	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT
			INS_ID_CLIENT, INS_ID, 'INVOICE', 'Добавление строки с/ф',
			CONVERT(VARCHAR(20), PR_DATE, 104) +
				':' + DIS_STR + ' - ' + dbo.MoneyFormat(INR_SALL)
		FROM
			dbo.InvoiceSaleTable z
			INNER JOIN dbo.InvoiceRowTable a ON a.INR_ID_INVOICE = z.INS_ID
			INNER JOIN dbo.DistrView b WITH(NOEXPAND) ON a.INR_ID_DISTR = DIS_ID
			INNER JOIN dbo.PeriodTable ON PR_ID = INR_ID_PERIOD
		WHERE INR_ID_INVOICE = @insid

	IF @print = 1
		EXEC dbo.INVOICE_PRINT_BY_ID_LIST @insid
	ELSE IF @returndataset = 1
		SELECT 0
		WHERE @insid IS NOT NULL

	EXEC dbo.BOOK_SALE_PROCESS @insid
	EXEC dbo.BOOK_PURCHASE_PROCESS @insid
END
GO
GRANT EXECUTE ON [dbo].[INVOICE_CREATE_BY_CONSIGN] TO rl_invoice_w;
GO