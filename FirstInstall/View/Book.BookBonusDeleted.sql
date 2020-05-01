USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Book].[BookBonusDeleted]
--WITH SCHEMABINDING
AS
	SELECT
		BB_ID_MASTER, BB_ID,
		PT_ID, PT_ID_MASTER, PT_NAME,
		BB_PERCENT,
		BB_DATE, BB_END
	FROM
		Book.BookBonusAll a
	WHERE BB_REF = 3