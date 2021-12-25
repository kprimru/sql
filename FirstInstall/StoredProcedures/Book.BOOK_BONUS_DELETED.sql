﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Book].[BOOK_BONUS_DELETED]
	@RC	INT	=	NULL	OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Book].[BookBonusDeleted]

	SELECT	@RC	=	@@ROWCOUNT
END
GO
GRANT EXECUTE ON [Book].[BOOK_BONUS_DELETED] TO rl_book_bonus_r;
GO
