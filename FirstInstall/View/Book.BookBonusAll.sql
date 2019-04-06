USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Book].[BookBonusAll] 
--WITH SCHEMABINDING
AS
	SELECT 
		BB_ID_MASTER, BB_ID, 
		PT_ID, PT_ID_MASTER, PT_NAME,
		BB_PERCENT, 
		BB_DATE, BB_END, BB_REF
	FROM 
		Book.BookBonusDetail		INNER JOIN
		Personal.PersonalTypeLast	ON	PT_ID_MASTER = BB_ID_PT