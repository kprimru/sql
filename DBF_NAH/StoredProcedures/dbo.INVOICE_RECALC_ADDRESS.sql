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
ALTER PROCEDURE [dbo].[INVOICE_RECALC_ADDRESS]
	@invid INT
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

		DECLARE @instype SMALLINT

		SELECT @instype = INS_ID_TYPE
		FROM dbo.InvoiceSaleTable
		WHERE INS_ID = @invid

		DECLARE @clientid INT

		SELECT @clientid = ISNULL(INS_ID_PAYER, INS_ID_CLIENT)
		FROM dbo.InvoiceSaleTable
		WHERE INS_ID = @invid

		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Обновление адресов', '№' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR)
			FROM
				dbo.InvoiceSaleTable
				--INNER JOIN #inv ON INS_ID = INV_ID
			WHERE INS_ID = @invid

		IF @instype = 1
		BEGIN
			-- на первичку
			UPDATE dbo.InvoiceSaleTable
			SET INS_CLIENT_NAME =
					(
						SELECT CL_FULL_NAME
						FROM 
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_ADDR =
					(
						SELECT
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
												A.CL_ID = Z.CL_ID
												AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
											)
									END
								FROM dbo.FinancingAddressTypeTable AS O_O
								WHERE FAT_DOC = 'INV_FIRST_BUY'
							)
						FROM 
							dbo.ClientTable Z
						WHERE CL_ID = @clientid
					),
				INS_CONSIG_NAME =
					(
						SELECT CL_FULL_NAME
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CONSIG_ADDR =
					(
						SELECT
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
												A.CL_ID = Z.CL_ID
												AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
											)
									END
								FROM dbo.FinancingAddressTypeTable AS O_O
								WHERE FAT_DOC = 'INV_FIRST_CONS'
							)
						FROM 
							dbo.ClientTable Z
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_INN =
					(
						SELECT CL_INN
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_KPP =
					(
						SELECT CL_KPP
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_IDENT =
					(
						SELECT TOP 1 CO_IDENT
						FROM
							dbo.ContractTable
						WHERE CO_ID_CLIENT = @clientid
						ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
					)
			WHERE INS_ID = @invid
		END
		ELSE IF @instype = 2
		BEGIN
			-- на аванс
			UPDATE dbo.InvoiceSaleTable
			SET INS_CLIENT_NAME =
					(
						SELECT CL_FULL_NAME
						FROM 
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_ADDR =
					(
						SELECT
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
												A.CL_ID = Z.CL_ID
												AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
											)
									END
								FROM dbo.FinancingAddressTypeTable AS O_O
								WHERE FAT_DOC = 'INV_INCOME_BUY'
							)
						FROM 
							dbo.ClientTable Z
						WHERE CL_ID = @clientid
					),
				INS_CONSIG_NAME =
					(
						SELECT CL_FULL_NAME
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CONSIG_ADDR =
					(
						SELECT
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
												A.CL_ID = Z.CL_ID
												AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
											)
									END
								FROM dbo.FinancingAddressTypeTable AS O_O
								WHERE FAT_DOC = 'INV_INCOME_CONS'
							)
						FROM 
							dbo.ClientTable Z
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_INN =
					(
						SELECT CL_INN
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_KPP =
					(
						SELECT CL_KPP
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_IDENT =
					(
						SELECT TOP 1 CO_IDENT
						FROM
							dbo.ContractTable
						WHERE CO_ID_CLIENT = @clientid
						ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
					)
			WHERE INS_ID = @invid
		END
		ELSE IF @instype = 3
		BEGIN
			-- на акт
			UPDATE dbo.InvoiceSaleTable
			SET INS_CLIENT_NAME =
					(
						SELECT CL_FULL_NAME
						FROM 
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_ADDR =
					(
						SELECT
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
												A.CL_ID = Z.CL_ID
												AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
											)
									END
								FROM dbo.FinancingAddressTypeTable AS O_O
								WHERE FAT_DOC = 'INV_ACT_BUY'
							)
						FROM 
							dbo.ClientTable Z
						WHERE CL_ID = @clientid
					),
				INS_CONSIG_NAME =
					(
						SELECT CL_FULL_NAME
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CONSIG_ADDR =
					(
						SELECT
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
												A.CL_ID = Z.CL_ID
												AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
											)
									END
								FROM dbo.FinancingAddressTypeTable AS O_O
								WHERE FAT_DOC = 'INV_ACT_CONS'
							)
						FROM 
							dbo.ClientTable Z
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_INN =
					(
						SELECT CL_INN
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_KPP =
					(
						SELECT CL_KPP
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_IDENT =
					(
						SELECT TOP 1 CO_IDENT
						FROM
							dbo.ContractTable
						WHERE CO_ID_CLIENT = @clientid
						ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
					)
			WHERE INS_ID = @invid

		END
		ELSE IF @instype = 4
		BEGIN
			-- на накладную
			UPDATE dbo.InvoiceSaleTable
			SET INS_CLIENT_NAME =
					(
						SELECT CL_FULL_NAME
						FROM 
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_ADDR =
					(
						SELECT
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
												A.CL_ID = Z.CL_ID
												AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
											)
									END
								FROM dbo.FinancingAddressTypeTable AS O_O
								WHERE FAT_DOC = 'INV_CONS_BUY'
							)
						FROM 
							dbo.ClientTable Z
						WHERE CL_ID = @clientid
					),
				INS_CONSIG_NAME =
					(
						SELECT CL_FULL_NAME
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CONSIG_ADDR =
					(
						SELECT
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
												A.CL_ID = Z.CL_ID
												AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
											)
									END
								FROM dbo.FinancingAddressTypeTable AS O_O
								WHERE FAT_DOC = 'INV_CONS_CONS'
							)
						FROM 
							dbo.ClientTable Z
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_INN =
					(
						SELECT CL_INN
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_CLIENT_KPP =
					(
						SELECT CL_KPP
						FROM
							dbo.ClientTable
						WHERE CL_ID = @clientid
					),
				INS_IDENT =
					(
						SELECT TOP 1 CO_IDENT
						FROM
							dbo.ContractTable
						WHERE CO_ID_CLIENT = @clientid
						ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
					)
			WHERE INS_ID = @invid


		END

		EXEC dbo.BOOK_SALE_PROCESS @invid
		EXEC dbo.BOOK_PURCHASE_PROCESS @invid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INVOICE_RECALC_ADDRESS] TO rl_invoice_w;
GO