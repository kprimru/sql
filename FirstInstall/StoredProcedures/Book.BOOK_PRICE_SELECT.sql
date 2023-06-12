﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Book].[BOOK_PRICE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Book].[BOOK_PRICE_SELECT]  AS SELECT 1')
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
