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
ALTER PROCEDURE [dbo].[CONSIGNMENT_RECALC_ADDRESS]
	@consid INT
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

		DECLARE @clientid INT

		SELECT @clientid = CSG_ID_CLIENT
		FROM dbo.ConsignmentTable
		WHERE CSG_ID = @consid

		UPDATE dbo.ConsignmentTable
		SET	CSG_CONSIGN_NAME = CL_FULL_NAME,
			CSG_CONSIGN_ADDRESS = CONSIG_ADDRESS,
			CSG_CONSIGN_INN = CL_INN,
			CSG_CONSIGN_KPP = CL_KPP,
			CSG_CONSIGN_OKPO = CL_OKPO,
			CSG_CLIENT_NAME = CL_FULL_NAME,
			CSG_CLIENT_ADDRESS = BUY_ADDRESS,
			CSG_CLIENT_PHONE = CL_PHONE,
			CSG_CLIENT_BANK = BANK
		FROM
			(
				SELECT 
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
					) AS CONSIG_ADDRESS,
					CL_INN, CL_KPP,
					CL_OKPO,
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
					) AS BUY_ADDRESS,
					CL_PHONE,
					('р.с ' + CL_ACCOUNT + ' в ' + BA_NAME + ', БИК ' + BA_BIK + ' корр/с ' + BA_LORO) AS BANK
				FROM
					dbo.ClientTable LEFT OUTER JOIN
					dbo.BankTable ON BA_ID = CL_ID_BANK
				WHERE CL_ID = @clientid
			) AS dt
		WHERE CSG_ID = @consid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_RECALC_ADDRESS] TO rl_consignment_w;
GO
