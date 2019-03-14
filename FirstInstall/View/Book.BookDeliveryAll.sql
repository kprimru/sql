USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [Book].[BookDeliveryAll] 
--WITH SCHEMABINDING
AS
	SELECT 
		BD_ID_MASTER, BD_ID, 		
		BD_PRICE, BD_COUNT,
		BD_DATE, BD_END, BD_REF
	FROM 
		Book.BookDeliveryDetail