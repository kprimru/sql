USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Book].[BOOK_BONUS_SELECT]
	@RC	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Book].[BookBonusActive]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Book].[BOOK_BONUS_SELECT] TO rl_book_bonus_r;
GO
