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
ALTER PROCEDURE [dbo].[INVOICE_DEFAULT_GET]
	@clientid INT
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
				(
					SELECT ISNULL(MAX(INS_NUM) + 1, 1)
					FROM dbo.InvoiceSaleTable
					WHERE INS_NUM_YEAR = RIGHT(DATEPART(yy, GETDATE()),2)
						AND INS_ID_ORG = (SELECT CL_ID_ORG FROM dbo.ClientTable WHERE CL_ID = @Clientid)
				) AS INS_NUM,
				RIGHT(DATEPART(yy, GETDATE()),2) AS INS_NUM_YEAR,
				CL_FULL_NAME AS INS_CLIENT_NAME,
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
									A.CL_ID = z.CL_ID
									AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
								)
						END
					FROM dbo.FinancingAddressTypeTable AS O_O
					WHERE FAT_DOC = 'INV_ACT_BUY'
				) AS INS_CLIENT_ADDR,
				CL_FULL_NAME AS INS_CONSIG_NAME,
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
									A.CL_ID = z.CL_ID
									AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
								)
						END
					FROM dbo.FinancingAddressTypeTable AS O_O
					WHERE FAT_DOC = 'INV_ACT_CONS'
				) AS INS_CONSIG_ADDR,
				CL_INN, CL_KPP,
				(
					SELECT INT_ID
					FROM dbo.InvoiceTypeTable
					WHERE INT_PSEDO = 'SIMPLE'
				) AS INT_ID,
				(
					SELECT INT_NAME
					FROM dbo.InvoiceTypeTable
					WHERE INT_PSEDO = 'SIMPLE'
				) AS INT_NAME,
				ORG_ID, ORG_SHORT_NAME,
				(
					SELECT TOP 1 CO_IDENT
					FROM
						dbo.ContractTable
					WHERE
						CO_ID_CLIENT = z.CL_ID
					ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
				) AS INS_IDENT
			FROM 
				dbo.ClientTable z LEFT OUTER JOIN
				dbo.OrganizationTable ON CL_ID_ORG = ORG_ID
			WHERE CL_ID = @clientid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INVOICE_DEFAULT_GET] TO rl_invoice_r;
GO
