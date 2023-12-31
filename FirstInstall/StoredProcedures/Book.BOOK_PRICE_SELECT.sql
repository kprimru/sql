USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Book].[BOOK_PRICE_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Book].[BookPriceActive]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Book].[BOOK_PRICE_SELECT] TO rl_book_price_r;
GO
