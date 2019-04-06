USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	26-06-2009
Описание:		добавить счет-фактуру на первичную оплату (?)
*/
CREATE PROCEDURE [dbo].[INVOICE_CREATE_BY_PRPAY]
	@client_id INT,
	@invdate SMALLDATETIME,
	@print BIT = 1,
	@insid INT OUTPUT,
	@returndataset BIT = 1
AS
BEGIN
	SET NOCOUNT ON;	
	
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
		SELECT DISTINCT	PRP_DATE, PRP_DOC
			FROM
				dbo.PrimaryPayTable INNER JOIN
				dbo.ClientDistrTable ON PRP_ID_DISTR = CD_ID_DISTR
			WHERE	PRP_ID_INVOICE IS NULL
				AND CD_ID_CLIENT = @client_id

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

	-- мастер-данные
	INSERT INTO dbo.InvoiceSaleTable(
		INS_ID_ORG, INS_DATE, INS_NUM, INS_NUM_YEAR, INS_ID_CLIENT,
		INS_CLIENT_NAME, INS_CLIENT_ADDR, INS_CONSIG_NAME, INS_CONSIG_ADDR,
		INS_CLIENT_INN, INS_CLIENT_KPP, INS_DOC_STRING,
		INS_ID_TYPE

		)
		SELECT TOP 1 
			ISNULL(PRP_ID_ORG, CL_ID_ORG), @invdate, 
			(
				SELECT ISNULL(MAX(INS_NUM) + 1, 1) 
				FROM dbo.InvoiceSaleTable 
				WHERE INS_NUM_YEAR = RIGHT(DATEPART(yy, @invdate),2)
					AND INS_ID_ORG = ISNULL(PRP_ID_ORG, CL_ID_ORG)
			),
			RIGHT(DATEPART(yy, @invdate),2),
			CL_ID,
			CL_FULL_NAME,
			(
				SELECT
					CASE 
						WHEN ISNULL(FAT_ID_ADDR_TYPE, '') = '' THEN FAT_TEXT
						ELSE 
							(
						/*	SELECT ISNULL(CT_PREFIX+CT_NAME+', '+ST_PREFIX+ST_NAME+', д.'+CA_HOME, CA_STR)
							FROM	
								dbo.ClientTable INNER JOIN
								dbo.ClientAddressView a ON CL_ID = CA_ID_CLIENT INNER JOIN
							WHERE  
								CL_ID = CD_ID_CLIENT
								AND CA_ID_TYPE = FAT_ID_ADDR_TYPE
						*/	
							-- 16.07.2009, Богдан В.С.						
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
								A.CL_ID = CD_ID_CLIENT
								AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
							)

					END
				FROM dbo.FinancingAddressTypeTable O_O
				WHERE FAT_DOC = 'INV_FIRST_BUY'
			),
			CL_FULL_NAME,
			(
				SELECT
					CASE 
						WHEN ISNULL(FAT_ID_ADDR_TYPE, '') = '' THEN FAT_TEXT
						ELSE 
							(
						/*	SELECT ISNULL(CT_PREFIX+CT_NAME+', '+ST_PREFIX+ST_NAME+', д.'+CA_HOME, CA_STR)										
							FROM	
								dbo.ClientTable INNER JOIN
								dbo.ClientAddressView a ON CL_ID = CA_ID_CLIENT 
							WHERE  
								CL_ID = CD_ID_CLIENT
								AND CA_ID_TYPE = FAT_ID_ADDR_TYPE
						*/
							-- 16.07.2009, Богдан В.С.						
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
								A.CL_ID = CD_ID_CLIENT
								AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
							)
					END
				FROM dbo.FinancingAddressTypeTable O_O
				WHERE FAT_DOC = 'INV_FIRST_CONS'
			),
			CL_INN, CL_KPP, @docstring,
			(
				SELECT INT_ID 
				FROM dbo.InvoiceTypeTable
				WHERE INT_PSEDO = 'PRIMARY'
			)

			FROM 
				dbo.PrimaryPayTable		A	INNER JOIN
				dbo.DistrTable			B	ON	B.DIS_ID = A.PRP_ID_DISTR	INNER JOIN
				dbo.ClientDistrTable	C	ON	B.DIS_ID = C.CD_ID_DISTR	LEFT JOIN
				dbo.ClientTable			D	ON	D.CL_ID	= C.CD_ID_CLIENT	INNER JOIN
				dbo.DistrDocumentView	H	ON	H.DIS_ID= B.DIS_ID			
			WHERE
				CD_ID_CLIENT = @client_id
				AND PRP_ID_INVOICE IS NULL
				AND NOT EXISTS (
					SELECT * FROM
						dbo.InvoiceRowTable		J	INNER JOIN
						dbo.InvoiceSaleTable	L	ON	L.INS_ID = J.INR_ID_INVOICE INNER JOIN
--						dbo.DistrDocumentView	K	ON	J.INR_ID_DISTR=K.DIS_ID
						dbo.InvoiceTypeTable	M	ON	M.INT_ID = L.INS_ID_TYPE
						WHERE	J.INR_ID_DISTR = B.DIS_ID
--								AND K.DOC_PSEDO='INV_FIRST'
								AND M.INT_PSEDO='PRIMARY'
					)
				AND DOC_PSEDO = 'INV_FIRST'
				AND DD_PRINT = 1
				AND PRP_PRICE <> 0

	SET @insid = SCOPE_IDENTITY()

	-- деталь-данные
	INSERT INTO dbo.InvoiceRowTable (INR_ID_INVOICE,
								 INR_GOOD, INR_NAME, INR_SUM, INR_ID_TAX, INR_TNDS, INR_SNDS, INR_SALL,
								 INR_ID_DISTR, INR_PPRICE, INR_UNIT) --, INR_ID_PERIOD)
		SELECT 
			@insid,
			GD_NAME, ISNULL(SYS_PREFIX, '') + ' ' + SYS_NAME,
			PRP_PRICE, E.TX_ID, E.TX_PERCENT, PRP_TAX_PRICE, PRP_TOTAL_PRICE,
			B.DIS_ID,
			PRP_TOTAL_PRICE, UN_NAME
		FROM 
			dbo.DistrTable			B									INNER JOIN
			dbo.SystemTable			C	ON	B.DIS_ID_SYSTEM=C.SYS_ID	INNER JOIN
			dbo.SaleObjectTable		D	ON	C.SYS_ID_SO=D.SO_ID			INNER JOIN
			dbo.TaxTable			E	ON	D.SO_ID_TAX=E.TX_ID			INNER JOIN
			dbo.PrimaryPayView		F	ON	F.DIS_ID=B.DIS_ID			INNER JOIN
			dbo.DistrDocumentView	I	ON	I.DIS_ID=B.DIS_ID			
		WHERE
			CD_ID_CLIENT = @client_id
			AND NOT EXISTS (
				SELECT * FROM 
					dbo.InvoiceRowTable		G	INNER JOIN
					dbo.InvoiceSaleTable	L	ON	INS_ID = INR_ID_INVOICE INNER JOIN
					dbo.InvoiceTypeTable	M	ON	INT_ID = INS_ID_TYPE
					WHERE
						F.DIS_ID = G.INR_ID_DISTR
						AND INT_PSEDO = 'PRIMARY'
				)
			AND DOC_PSEDO = 'INV_FIRST'
			AND DD_PRINT = 1
			AND PRP_ID_INVOICE IS NULL
			AND PRP_PRICE <> 0

	
	-- заносим в PrimaryPay сведения о созданной с/ф (в PRP_ID_INVOICE)
	UPDATE dbo.PrimaryPayTable SET PRP_ID_INVOICE=@insid
		WHERE
			PRP_ID IN (
			SELECT PRP_ID
				FROM	dbo.PrimaryPayTable					INNER JOIN
						dbo.ClientDistrTable	ON	PRP_ID_DISTR = CD_ID_DISTR	INNER JOIN
						dbo.DistrDocumentView	ON	PRP_ID_DISTR = DIS_ID
					WHERE	CD_ID_CLIENT = @client_id
							AND DOC_PSEDO='INV_FIRST'
							AND DD_PRINT = 1
							AND PRP_PRICE <> 0
			)
			AND PRP_ID_INVOICE IS NULL

	/*
	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT INS_ID_CLIENT, @insid, 'INVOICE', 'Создание с/ф на первичку', INS_DATA
		FROM dbo.InvoiceProtocolView
		WHERE INS_ID = @insid
	*/
	
	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Создание с/ф на первичку', '№' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) + ' от ' + CONVERT(VARCHAR(20), INS_DATE, 104)
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
 		SELECT 0
		WHERE @insid IS NOT NULL	
		
	EXEC dbo.BOOK_SALE_PROCESS @insid
	EXEC dbo.BOOK_PURCHASE_PROCESS @insid
END