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

ALTER PROCEDURE [dbo].[CONSIGNMENT_CREATE]
	@clientid INT,
	@periodid SMALLINT,
	@consdate SMALLDATETIME,
	@soid SMALLINT,
	@consid INT OUTPUT
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

		INSERT INTO dbo.ConsignmentTable
			(
				CSG_ID_ORG, 
				CSG_ID_CLIENT,
				CSG_CONSIGN_NAME,
				CSG_CONSIGN_ADDRESS,
				CSG_CONSIGN_INN,
				CSG_CONSIGN_KPP,
				CSG_CONSIGN_OKPO,
				CSG_CLIENT_NAME,
				CSG_CLIENT_ADDRESS,
				CSG_CLIENT_PHONE,
				CSG_CLIENT_BANK,
				CSG_FOUND, 
				CSG_NUM, 
				CSG_DATE,
				CSG_ID_PAYER
			)
		SELECT 
			CL_ID_ORG, @clientid, 
			CL_FULL_NAME,
			(
				SELECT
					CASE 
						WHEN ISNULL(FAT_ID_ADDR_TYPE, '') = '' THEN FAT_TEXT
						ELSE 
							(	
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
									A.CL_ID = @clientid
									AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
								)
						END
				FROM dbo.FinancingAddressTypeTable AS O_O
				WHERE FAT_DOC = 'INV_CONS_CONS'
			),
			CL_INN, CL_KPP,
			CL_OKPO,
			CL_FULL_NAME, 
			(
				SELECT
					CASE 
						WHEN ISNULL(FAT_ID_ADDR_TYPE, '') = '' THEN FAT_TEXT
						ELSE 
							(	
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
									A.CL_ID = @clientid
									AND B.CA_ID_TYPE = FAT_ID_ADDR_TYPE
								)
						END
				FROM dbo.FinancingAddressTypeTable AS O_O
				WHERE FAT_DOC = 'INV_CONS_BUY'
			),
			CL_PHONE,
			CASE LTRIM(RTRIM(ISNULL(CL_ACCOUNT, '')))
				WHEN '' THEN ''
				ELSE 'р.с ' + CL_ACCOUNT 
			END + 
			CASE LTRIM(RTRIM(ISNULL(BA_NAME, '')))
				WHEN '' THEN ''
				ELSE ' в ' + BA_NAME
			END + 
			CASE LTRIM(RTRIM(ISNULL(BA_BIK, '')))
				WHEN '' THEN ''
				ELSE ', БИК ' + BA_BIK
			END + 
			CASE LTRIM(RTRIM(ISNULL(BA_LORO, '')))
				WHEN '' THEN ''
				ELSE ' корр/с ' + BA_LORO
			END,
			'', NULL, @consdate, CL_ID_PAYER
		FROM 
			dbo.ClientTable LEFT OUTER JOIN
			dbo.BankTable ON BA_ID = CL_ID_BANK
		WHERE CL_ID = @clientid

		--DECLARE @consid INT

		SELECT @consid = SCOPE_IDENTITY()

		IF @consid = NULL
			RETURN
		
		DECLARE @insid INT

		IF @consdate <= '20101231'
		BEGIN
			EXEC dbo.INVOICE_CREATE_BY_CONSIGN @consid, @consdate, 1, 0, @insid OUTPUT

			UPDATE dbo.ConsignmentTable
			SET	CSG_NUM = 
					(
						SELECT INS_NUM
						FROM dbo.InvoiceSaleTable
						WHERE INS_ID = @insid
					)
			WHERE CSG_ID = @consid	
		END
		ELSE
		BEGIN
			UPDATE dbo.ConsignmentTable
			SET CSG_NUM = ISNULL(
					(
						SELECT MAX(CSG_NUM) + 1
						FROM dbo.ConsignmentTable
						WHERE DATEPART(YEAR, CSG_DATE) = DATEPART(YEAR, @consdate)
					), 1)
			WHERE CSG_ID = @consid
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CONSIGNMENT_CREATE] TO rl_consignment_w;
GO