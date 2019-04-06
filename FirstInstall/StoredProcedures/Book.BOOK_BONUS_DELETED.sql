USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Book].[BOOK_BONUS_DELETED]
	@RC	INT	=	NULL	OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Book].[BookBonusDeleted]
	
	SELECT	@RC	=	@@ROWCOUNT
END
