USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [Book].[BookPriceLast] 
--WITH SCHEMABINDING
AS
	SELECT 
		BP_ID_MASTER, BP_ID, 
		HLF_ID, HLF_ID_MASTER, HLF_NAME,
		BP_PRICE, 
		BP_DATE, BP_END
	FROM 
		Book.BookPriceAll a
	WHERE BP_REF IN (1, 3)