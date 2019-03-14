USE [BuhDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SYSTEM_LIST_SELECT]
	@DATA	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @DATA IS NULL
		SELECT SystemID, SystemPrefix + ' ' + SystemName AS SystemFullName, SystemPriceOnline2
		FROM 
			dbo.SystemTable a
			INNER JOIN dbo.SystemGroupTable b ON a.SystemGroupID = b.SystemGroupID
		ORDER BY SystemGroupOrder, SystemOrder
	ELSE
	BEGIN
		DECLARE @xml XML
		
		SET @XML = CAST(@DATA AS XML)
		
		SELECT 
			a.SystemID, SystemPrefix + ' ' + SystemName AS SystemFullName, SystemPriceOnline2,
			PRICE AS PriceRecommend,
			CASE SystemReg 
				WHEN 'IPK_BUH' THEN 
									(
										SELECT SUM(c.value('@price', 'MONEY'))
										FROM 
											@XML.nodes('/root/item') AS a(c)
											INNER JOIN dbo.SystemTable ON c.value('@id', 'INT') = SystemID
										WHERE SystemReg IN ('MOS', 'BUHL')
									) * 1.5
				WHEN 'IPK_BUHU' THEN 
									(
										SELECT SUM(c.value('@price', 'MONEY'))
										FROM 
											@XML.nodes('/root/item') AS a(c)
											INNER JOIN dbo.SystemTable ON c.value('@id', 'INT') = SystemID
										WHERE SystemReg IN ('MOS', 'BUHUL')
									) * 1.5
				WHEN 'RLAW020' THEN (
										SELECT c.value('@price', 'MONEY') 
										FROM 
											@XML.nodes('/root/item') AS a(c)
											INNER JOIN dbo.SystemTable ON c.value('@id', 'INT') = SystemID
										WHERE SystemReg = 'MLAW'
									) * 1.5
				ELSE PRICE * 1.5
			END AS PriceCoef
		FROM
			(
				SELECT
					c.value('@id', 'INT') AS ID,
					c.value('@price', 'MONEY') AS PRICE				
				FROM @XML.nodes('/root/item') AS a(c)
			) AS t
			INNER JOIN dbo.SystemTable a ON a.SystemID = t.ID
			INNER JOIN dbo.SystemGroupTable b ON a.SystemGroupID = b.SystemGroupID
		ORDER BY SystemGroupOrder, SystemOrder
	END	
END
