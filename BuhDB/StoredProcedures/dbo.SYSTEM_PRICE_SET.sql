USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_PRICE_SET]
	@DATA	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @xml XML
		
	SET @XML = CAST(@DATA AS XML)
		
	UPDATE a
	SET SystemPriceOnline2 = PRICE,
		SystemPriceRec = PRICE_REC
	FROM
		dbo.SystemTable a
		INNER JOIN 
			(
				SELECT
					c.value('@id', 'INT') AS ID,
					c.value('@price', 'MONEY') AS PRICE,			
					c.value('@recprice', 'MONEY') AS PRICE_REC
				FROM @XML.nodes('/root/item') AS a(c)
			) AS t ON a.SystemID = t.ID		
			
	SELECT 1	
END
