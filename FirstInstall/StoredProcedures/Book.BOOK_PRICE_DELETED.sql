USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Book].[BOOK_PRICE_DELETED]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Book].[BookPriceDeleted]

	SELECT @RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Book].[BOOK_PRICE_DELETED] TO rl_book_price_r;
GO