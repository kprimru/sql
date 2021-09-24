USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BOOK_DELETE]
	@ID		INT,
	@TYPE	NVARCHAR(32)
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

		IF @TYPE = 'SALE'
		BEGIN
			DELETE FROM dbo.BookSaleDetail
			WHERE ID_SALE = @ID

			DELETE FROM dbo.BookSale
			WHERE ID = @ID
		END
		ELSE IF @TYPE = 'PURCHASE'
		BEGIN
			DELETE FROM dbo.BookPurchaseDetail
			WHERE ID_PURCHASE = @ID

			DELETE FROM dbo.BookPurchase
			WHERE ID = @ID
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[BOOK_DELETE] TO rl_book_sale_p;
GO
