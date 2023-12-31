USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BOOK_DATA_GET]
	@ID		INT,
	@TYPE	NVARCHAR(16)
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

		IF @TYPE = N'SALE'
			SELECT ORG_ID, ORG_PSEDO, INS_ID, INS_NUM, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE
			FROM
				dbo.BookSale a
				INNER JOIN dbo.OrganizationTable b ON a.ID_ORG = b.ORG_ID
				INNER JOIN dbo.InvoiceSaleTable c ON INS_ID = ID_INVOICE
			WHERE ID = @ID
		ELSE IF @TYPE = N'PURCHASE'
			SELECT ORG_ID, ORG_PSEDO, ID_AVANS, d.INS_NUM AS AVANS_NUM, ID_INVOICE, c.INS_NUM AS INVOICE_NUM, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE, PURCHASE_DATE
			FROM
				dbo.BookPurchase a
				INNER JOIN dbo.OrganizationTable b ON a.ID_ORG = b.ORG_ID
				INNER JOIN dbo.InvoiceSaleTable c ON c.INS_ID = ID_INVOICE
				INNER JOIN dbo.InvoiceSaleTable d ON d.INS_ID = ID_AVANS
			WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[BOOK_DATA_GET] TO rl_book_sale_p;
GO
