USE [DBF]
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
CREATE PROCEDURE [dbo].[INVOICE_CREATE_BY_ACT]
	@actid INT,
	@invdate SMALLDATETIME,
	@reserve BIT,
	@print BIT,
	@insid INT OUTPUT,
	@returndataset BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	-- 1 выбрать мастер-данные для счет-фактуры

	--DECLARE @insid INT

	IF NOT EXISTS
		(
			SELECT * 
			FROM dbo.ActTable 
			WHERE ACT_ID = @actid AND ACT_ID_INVOICE IS NULL
		)
		RETURN

	IF NOT EXISTS
		(
			SELECT *
			FROM 
				dbo.ActDistrTable INNER JOIN
				dbo.DistrView a ON DIS_ID = AD_ID_DISTR INNER JOIN
				dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID
			WHERE AD_ID_ACT = @actid 
				AND DOC_PSEDO = 'INV_ACT' 
				AND DD_PRINT = 1 
				AND AD_TOTAL_PRICE <> 0
		)
		RETURN

	DECLARE @docstring varchar(1000)
		SET @docstring = ''
		
	IF OBJECT_ID('tempdb..#doc') IS NOT NULL
		DROP TABLE #doc

	CREATE TABLE #doc
		(
			IN_DATE SMALLDATETIME,
			IN_PAY_NUM VARCHAR(20)
		)

	INSERT INTO #doc
		SELECT DISTINCT	IN_PAY_DATE, IN_PAY_NUM
			FROM
				dbo.ActTable INNER JOIN
				dbo.ActDistrTable ON ACT_ID = AD_ID_ACT INNER JOIN
				dbo.IncomeDistrTable ON ID_ID_DISTR = AD_ID_DISTR 
								AND ID_ID_PERIOD = AD_ID_PERIOD INNER JOIN
				dbo.IncomeTable ON IN_ID = ID_ID_INCOME 
							--AND ACT_ID_CLIENT = IN_ID_CLIENT
				
			WHERE	ACT_ID = @actid AND
					ACT_ID_INVOICE IS NULL
					AND IN_DATE <= ACT_DATE

	SELECT @docstring = @docstring + '№ ' + IN_PAY_NUM + ' от ' + CONVERT(VARCHAR, IN_DATE, 104) + '; '
	FROM
		(
			SELECT 
			T.IN_DATE,
			STUFF(
					(
						SELECT ',' + TT.IN_PAY_NUM 
						FROM 
							(
								SELECT DISTINCT IN_PAY_NUM
								FROM #doc O_O
								WHERE O_O.IN_DATE = T.IN_DATE						
							) TT
						ORDER BY TT.IN_PAY_NUM FOR XML PATH('')
					), 1, 1, ''
				) IN_PAY_NUM
			FROM #doc T
			GROUP BY T.IN_DATE			
		) AS O_O
	ORDER BY O_O.IN_DATE

	IF OBJECT_ID('tempdb..#doc') IS NOT NULL
		DROP TABLE #doc
	
	
	IF @docstring <> ''
		SET @docstring = LEFT(@docstring, LEN(@docstring) - 1)

	INSERT INTO dbo.InvoiceSaleTable
				(
					INS_ID_ORG, INS_DATE, INS_NUM, INS_NUM_YEAR, INS_ID_CLIENT, 
					INS_CLIENT_NAME, INS_CLIENT_ADDR, INS_CONSIG_NAME, INS_CONSIG_ADDR,
					INS_CLIENT_INN, INS_CLIENT_KPP, INS_DOC_STRING, INS_RESERVE, 
					INS_ID_TYPE, INS_ID_PAYER, INS_IDENT
				)
		SELECT 
			ACT_ID_ORG, ACT_DATE, 
			(
				SELECT ISNULL(MAX(INS_NUM) + 1, 1) 
				FROM dbo.InvoiceSaleTable 
				WHERE INS_NUM_YEAR = RIGHT(DATEPART(yy, @invdate),2)
					AND INS_ID_ORG = ACT_ID_ORG
			),
			RIGHT(DATEPART(yy, @invdate),2),
			ACT_ID_CLIENT, 
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
								CL_ID = ACT_ID_CLIENT
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
								A.CL_ID = ISNULL(ACT_ID_PAYER, ACT_ID_CLIENT)
								AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
							)
					END
				FROM dbo.FinancingAddressTypeTable AS O_O
				WHERE FAT_DOC = 'INV_ACT_BUY'
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
								CL_ID = ACT_ID_CLIENT
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
								A.CL_ID = ISNULL(ACT_ID_PAYER, ACT_ID_CLIENT)
								AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
							)
					END
				FROM dbo.FinancingAddressTypeTable AS O_O
				WHERE FAT_DOC = 'INV_ACT_CONS'
			),
			CL_INN, CL_KPP, 
			@docstring,
			@reserve, 
			(
				SELECT INT_ID 
				FROM dbo.InvoiceTypeTable
				WHERE INT_PSEDO = 'ACT'
			), ACT_ID_PAYER,
			(
					SELECT TOP 1 CO_IDENT
					FROM 
						dbo.ContractTable
					WHERE 
						CO_ID_CLIENT = CL_ID
					ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
				) AS INS_IDENT
		FROM 
			dbo.ActTable LEFT OUTER JOIN
			dbo.ClientTable ON CL_ID = ISNULL(ACT_ID_PAYER, ACT_ID_CLIENT)
		WHERE ACT_ID = @actid

	SELECT @insid = SCOPE_IDENTITY()

	INSERT INTO dbo.InvoiceRowTable
				(
					INR_ID_INVOICE, INR_ID_DISTR, INR_ID_PERIOD,
					INR_GOOD, INR_NAME, INR_SUM, INR_ID_TAX, INR_TNDS,
					INR_SNDS, INR_SALL, INR_PPRICE, INR_UNIT					
				)
			SELECT 
				@insid, AD_ID_DISTR, AD_ID_PERIOD, 
				GD_NAME, 
				CASE ISNULL(DF_NAME, '') WHEN '' THEN ISNULL(SYS_PREFIX, '') + ' ' + SYS_NAME ELSE DF_NAME END, 
				AD_PRICE, AD_ID_TAX, TX_PERCENT,
				AD_TAX_PRICE, AD_TOTAL_PRICE, AD_PAYED_PRICE, UN_NAME
			FROM 
				dbo.ActDistrTable INNER JOIN
				dbo.DistrView a ON DIS_ID = AD_ID_DISTR INNER JOIN
				dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID INNER JOIN
				dbo.SaleObjectTable ON SO_ID = SYS_ID_SO INNER JOIN
				dbo.TaxTable ON SO_ID_TAX = TX_ID LEFT OUTER JOIN
				dbo.DistrFinancingTable ON DF_ID_DISTR = a.DIS_ID
			WHERE AD_ID_ACT = @actid AND DOC_PSEDO = 'INV_ACT' AND DD_PRINT = 1
	
	UPDATE dbo.ActTable
	SET ACT_ID_INVOICE = @insid
	WHERE ACT_ID = @actid

	/*
	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT INS_ID_CLIENT, @insid, 'INVOICE', 'Создание с/ф по акту', INS_DATA
		FROM dbo.InvoiceProtocolView
		WHERE INS_ID = @insid
	*/
	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Создание с/ф по акту', '№' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) + ' от ' + CONVERT(VARCHAR(20), INS_DATE, 104)
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
			INNER JOIN dbo.DistrView b ON a.INR_ID_DISTR = DIS_ID
			INNER JOIN dbo.PeriodTable ON PR_ID = INR_ID_PERIOD
		WHERE INR_ID_INVOICE = @insid

	IF @print = 1 
		EXEC dbo.INVOICE_PRINT_BY_ID_LIST @insid
	ELSE IF @returndataset = 1
		EXEC dbo.INVOICE_PRINT_BY_ID_LIST NULL
		
	EXEC dbo.BOOK_SALE_PROCESS @insid
	EXEC dbo.BOOK_PURCHASE_PROCESS @insid
END
