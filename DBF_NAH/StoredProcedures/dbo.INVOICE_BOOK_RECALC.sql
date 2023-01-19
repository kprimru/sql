USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INVOICE_BOOK_RECALC]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INVOICE_BOOK_RECALC]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[INVOICE_BOOK_RECALC]
	@ID	INT
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

		EXEC dbo.BOOK_SALE_PROCESS @ID
		EXEC dbo.BOOK_PURCHASE_PROCESS @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INVOICE_BOOK_RECALC] TO rl_book_buy_p;
GRANT EXECUTE ON [dbo].[INVOICE_BOOK_RECALC] TO rl_book_sale_p;
GO
