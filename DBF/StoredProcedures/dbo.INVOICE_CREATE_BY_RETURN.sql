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
ALTER PROCEDURE [dbo].[INVOICE_CREATE_BY_RETURN]
	@inid INT,
	@invdate SMALLDATETIME,
	@reserve BIT,
	@print BIT,
	@insid INT OUTPUT,
	@returndataset BIT = 1
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
	
		IF NOT EXISTS
			(
				SELECT * 
				FROM dbo.IncomeTable 
				WHERE IN_ID = @inid				
					AND IN_ID_INVOICE IS NULL 
					AND IN_SUM < 0
			)
			RETURN

		IF NOT EXISTS
			(
				SELECT *			
				FROM 
					dbo.IncomeTable INNER JOIN
					dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME INNER JOIN
					dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR INNER JOIN
					dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID INNER JOIN
					dbo.SaleObjectTable ON SO_ID = SYS_ID_SO INNER JOIN
					dbo.TaxTable ON SO_ID_TAX = TX_ID
				WHERE DOC_PSEDO = 'INV_INCOME' AND DD_PRINT = 1
					AND IN_ID = @inid				
					AND ID_PRICE < 0
			)
			RETURN

		DECLARE @docstring varchar(MAX)
			SET @docstring = ''
		
		IF OBJECT_ID('tempdb..#doc') IS NOT NULL
			DROP TABLE #doc

		CREATE TABLE #doc
			(
				IN_DATE SMALLDATETIME,
				IN_PAY_NUM VARCHAR(20)
			)

		INSERT INTO #doc
			SELECT DISTINCT	IN_DATE, IN_PAY_NUM
			FROM
				dbo.IncomeTable inner join 
				dbo.IncomeDistrTable on IN_ID = ID_ID_INCOME
			WHERE	IN_ID = @inid
				AND IN_ID_INVOICE IS NULL
				AND IN_DATE <= @invdate

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
						INS_ID_TYPE, INS_INCOME_DATE, INS_ID_PAYER, INS_IDENT
					)
			SELECT DISTINCT
				CL_ID_ORG, @invdate, 
				(
					SELECT ISNULL(MAX(INS_NUM) + 1, 1) 
					FROM dbo.InvoiceSaleTable 
					WHERE INS_NUM_YEAR = RIGHT(DATEPART(yy, @invdate),2)
						AND CL_ID_ORG = INS_ID_ORG
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
	/*							SELECT ISNULL(CT_PREFIX+CT_NAME+', '+ST_PREFIX+ST_NAME+', д.'+CA_HOME, CA_STR)										
								FROM	
									dbo.ClientTable INNER JOIN
									dbo.ClientAddressView a ON CL_ID = CA_ID_CLIENT 
								WHERE  
									CL_ID = z.CL_ID
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
									A.CL_ID = ISNULL(z.CL_ID_PAYER, z.CL_ID)
									AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
								)
						END
					FROM dbo.FinancingAddressTypeTable AS O_O
					WHERE FAT_DOC = 'INV_INCOME_BUY'
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
									CL_ID = z.CL_ID
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
									A.CL_ID = ISNULL(z.CL_ID_PAYER, z.CL_ID)
									AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
								)
						END
					FROM dbo.FinancingAddressTypeTable AS O_O
					WHERE FAT_DOC = 'INV_INCOME_CONS'
				),
				CL_INN, CL_KPP, @docstring,
				@reserve, 
				(
					SELECT INT_ID 
					FROM dbo.InvoiceTypeTable
					WHERE INT_PSEDO = 'RETURN'
				), 
				(
					SELECT TOP 1 IN_DATE
					FROM dbo.IncomeTable
					WHERE IN_ID = @inid
						AND IN_DATE <= @invdate
						AND IN_ID_INVOICE IS NULL
					ORDER BY IN_DATE DESC
				), CL_ID_PAYER, 
				(
						SELECT TOP 1 CO_IDENT
						FROM 
							dbo.ContractTable
						WHERE 
							CO_ID_CLIENT = CL_ID
						ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
					) AS INS_IDENT
			FROM 			
				dbo.ClientTable z	
				INNER JOIN dbo.IncomeTable ON IN_ID_CLIENT = CL_ID		
			WHERE IN_ID = @inid
				
				/*AND ISNULL(
					(
						SELECT SUM(AD_TOTAL_PRICE)
						FROM 
							dbo.ActTable
							INNER JOIN dbo.ActDistrTable ON AD_ID_ACT = ACT_ID
							INNER JOIN dbo.IncomeTable ON IN_ID_CLIENT = CL_ID
							INNER JOIN dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID					
						WHERE ACT_ID_CLIENT = IN_ID_CLIENT AND IN_ID_ORG = ACT_ID_ORG AND AD_ID_DISTR = ID_ID_DISTR AND ID_ID_PERIOD = AD_ID_PERIOD 
							AND IN_ID_INVOICE IS NULL AND IN_DATE <= @invdate
					), 0) <> (SELECT SUM(IN_SUM) FROM dbo.IncomeTable y WHERE IN_ID_CLIENT = CL_ID AND IN_ID_INVOICE IS NULL AND IN_DATE <= @invdate)*/
				/*AND EXISTS
					(
						SELECT *
						FROM
							(
								SELECT ID_ID_DISTR, SUM(ID_PRICE) AS ID_PRICE, 
									ISNULL(
        										(
    												SELECT TOP 1 SL_REST 
	        										FROM dbo.SaldoView b
													WHERE b.SL_ID_DISTR = ID_ID_DISTR	
    		    										AND b.SL_ID_CLIENT = IN_ID_CLIENT
														AND SL_DATE < IN_DATE
        											ORDER BY SL_DATE DESC, SL_ID DESC
												), 0) AS SL_REST
								FROM 
									dbo.IncomeTable
									INNER JOIN dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME
								WHERE IN_ID_CLIENT = CL_ID 
									AND IN_ID_INVOICE IS NULL 
									AND IN_DATE <= @invdate		
								GROUP BY ID_ID_DISTR, IN_ID_CLIENT, IN_DATE			
							) AS o_O
						WHERE ABS(SL_REST) < ID_PRICE OR SL_REST > 0				
					)*/

		SELECT @insid = SCOPE_IDENTITY()

		IF @insid IS NOT NULL
			INSERT INTO dbo.InvoiceRowTable
						(
							INR_ID_INVOICE, INR_ID_DISTR, INR_GOOD, INR_NAME, INR_SUM, INR_ID_TAX,
							INR_TNDS, INR_SNDS, INR_SALL, INR_PPRICE, INR_UNIT,
							INR_ID_PERIOD
						)
				SELECT 
					@insid, ID_ID_DISTR, GD_NAME, ISNULL(SYS_PREFIX, '') + ' ' + SYS_NAME, 
					-- стоимость без НДС
					CAST(ROUND((ID_PRICE - DELTA) /(1 + ROUND(TX_PERCENT / 100, 2)), 2) AS MONEY), 
					TX_ID, TX_PERCENT,
					-- НДС
					CAST(ROUND((ID_PRICE - DELTA) - CAST(ROUND((ID_PRICE - DELTA) /(1 + ROUND(TX_PERCENT / 100, 2)), 2) AS MONEY), 2) AS MONEY), 
					(ID_PRICE - DELTA), 
					NULL, UN_NAME,
					ID_ID_PERIOD
				FROM 			
					(
						SELECT ID_ID_DISTR, GD_NAME, SYS_PREFIX, SYS_NAME, ID_PRICE, TX_PERCENT, UN_NAME, ID_ID_PERIOD,	TX_ID,
							0 AS DELTA
						FROM
							(
							SELECT
								ID_ID_DISTR, GD_NAME, SYS_PREFIX, SYS_NAME, SUM(ABS(ID_PRICE)) AS ID_PRICE, TX_PERCENT, UN_NAME, NULL ID_ID_PERIOD, TX_ID
							FROM
								dbo.IncomeTable
								INNER JOIN dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME 
								INNER JOIN dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR 
								INNER JOIN dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID 
								INNER JOIN dbo.SaleObjectTable ON SO_ID = SYS_ID_SO 
								INNER JOIN dbo.TaxTable ON SO_ID_TAX = TX_ID
							WHERE DOC_PSEDO = 'INV_INCOME' 
								AND DD_PRINT = 1
								AND IN_ID = @inid
								AND IN_ID_INVOICE IS NULL
								AND IN_DATE <= @invdate
								AND ID_PRICE < 0
							GROUP BY ID_ID_DISTR, GD_NAME, SYS_PREFIX, SYS_NAME, TX_PERCENT, UN_NAME, TX_ID, IN_ID_CLIENT, IN_DATE
						) AS o_O
					) AS t	
		
		IF @insid IS NOT NULL
			UPDATE dbo.IncomeTable
			SET IN_ID_INVOICE = @insid
			WHERE IN_ID = @inid
				AND IN_DATE <= @invdate
				AND IN_ID_INVOICE IS NULL		
		ELSE
			UPDATE dbo.IncomeTable
			SET IN_ID_INVOICE = 
				(
					SELECT INS_ID 
					FROM dbo.InvoiceSaleTable
					WHERE INS_NUM = '0'
						AND INS_NUM_YEAR = '0'
				)
			WHERE IN_ID = @inid
				AND IN_DATE <= @invdate
				AND IN_ID_INVOICE IS NULL
			

		/*
		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT INS_ID_CLIENT, @insid, 'INVOICE', 'Создание с/ф по оплате', INS_DATA
			FROM dbo.InvoiceProtocolView
			WHERE INS_ID = @insid
		*/
		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Создание с/ф по возвратам', '№' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) + ' от ' + CONVERT(VARCHAR(20), INS_DATE, 104)
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
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[INVOICE_CREATE_BY_RETURN] TO rl_invoice_w;
GO