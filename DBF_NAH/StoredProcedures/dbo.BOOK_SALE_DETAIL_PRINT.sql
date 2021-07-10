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
ALTER PROCEDURE [dbo].[BOOK_SALE_DETAIL_PRINT]
	@orgid SMALLINT,
	@begindate SMALLDATETIME,
	@enddate SMALLDATETIME
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

		UPDATE dbo.GlobalSettingsTable
		SET GS_VALUE = CONVERT(VARCHAR(20), @begindate, 104)
		WHERE GS_NAME = 'BOOK_START'

		UPDATE dbo.GlobalSettingsTable
		SET GS_VALUE = CONVERT(VARCHAR(20), @enddate, 104)
		WHERE GS_NAME = 'BOOK_FINISH'

		IF @begindate < '20150101'
			SELECT 
				INS_DATE, INS_NUM, INS_NUM_YEAR, INS_CLIENT_NAME, INS_CLIENT_INN,
				INS_INCOME_DATE,
				(
					SELECT SUM(INR_SUM*ISNULL(INR_COUNT,1))
					FROM dbo.InvoiceRowTable
					WHERE INR_ID_INVOICE = INS_ID
				) AS INV_PRICE,
				(
					SELECT SUM(INR_SNDS)
					FROM dbo.InvoiceRowTable
					WHERE INR_ID_INVOICE = INS_ID
				) AS INV_TAX_PRICE,
				(
					SELECT SUM(INR_SALL)
					FROM dbo.InvoiceRowTable
					WHERE INR_ID_INVOICE = INS_ID
				) AS INV_TOTAL_PRICE,
				(
					SELECT TOP 1 TX_PERCENT
					FROM
						dbo.TaxTable INNER JOIN
						dbo.InvoiceRowTable ON INR_ID_TAX = TX_ID
					WHERE INR_ID_INVOICE = INS_ID
				) AS TX_PERCENT
			FROM
				dbo.InvoiceSaleTable INNER JOIN
				dbo.InvoiceTypeTable ON INT_ID = INS_ID_TYPE
			WHERE INS_DATE BETWEEN @begindate AND @enddate
				AND INS_ID_ORG = @orgid
				AND INT_SALE = 1
			ORDER BY INS_DATE, INS_NUM_YEAR, INS_NUM
		ELSE
			EXEC dbo.BOOK_SALE_1C @BEGINDATE, @ENDDATE, @ORGID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[BOOK_SALE_DETAIL_PRINT] TO rl_book_sale_p;
GO