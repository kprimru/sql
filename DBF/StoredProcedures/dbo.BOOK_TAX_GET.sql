USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[BOOK_TAX_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[BOOK_TAX_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[BOOK_TAX_GET]
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
			SELECT TX_ID, TX_CAPTION, TX_PERCENT, SUM(S_NDS) AS S_NDS, SUM(S_BEZ_NDS) AS S_BEZ_NDS, SUM(S_ALL) AS S_ALL
			FROM
				dbo.TaxTable a
				LEFT OUTER JOIN dbo.BookSaleDetail b ON a.TX_ID = b.ID_TAX AND b.ID_SALE = @ID
			GROUP BY TX_ID, TX_CAPTION, TX_PERCENT
			ORDER BY TX_PERCENT DESC
		ELSE IF @TYPE = N'PURCHASE'
			SELECT TX_ID, TX_CAPTION, TX_PERCENT, SUM(S_NDS) AS S_NDS, SUM(S_BEZ_NDS) AS S_BEZ_NDS, SUM(S_ALL) AS S_ALL
			FROM
				dbo.TaxTable a
				LEFT OUTER JOIN dbo.BookPurchaseDetail b ON a.TX_ID = b.ID_TAX AND b.ID_PURCHASE = @ID
			GROUP BY TX_ID, TX_CAPTION, TX_PERCENT
			ORDER BY TX_PERCENT DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[BOOK_TAX_GET] TO rl_book_sale_p;
GO
