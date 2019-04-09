USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[DISTR_PRICE_GET]
	@LIST		NVARCHAR(MAX),
	@TYPE		TINYINT,
	@MONTH		UNIQUEIDENTIFIER,
	@DISCOUNT	DECIMAL(8, 4),
	@INFLATION	DECIMAL(8, 4),
	@SPREAD		MONEY
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML
	
	SET @XML = CAST(@LIST AS XML)
	
	IF @TYPE = 1
		SELECT ID, PRICE
		FROM
			(
				SELECT 
					a.ID,
					CONVERT(MONEY, ROUND(PRICE * DistrTypeCoef * (100 - @DISCOUNT) / 100 * (1 + @INFLATION / 100.0), 0)) AS PRICE
				FROM 
					(
						SELECT 			
							c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID,
							c.value('(@sys)', 'INT') AS SYS_ID,
							c.value('(@net)', 'INT') AS NET_ID							
						FROM @xml.nodes('/root/item') AS a(c)
					) AS a
					INNER JOIN dbo.SystemTable b ON a.SYS_ID = b.SystemID
					INNER JOIN dbo.DistrTypeTable c ON a.NET_ID = c.DistrTypeID
					INNER JOIN Price.SystemPrice d ON ID_SYSTEM = SYS_ID
				WHERE ID_MONTH = @MONTH
			) AS o_O
	ELSE
		SELECT ID, PRICE
		FROM
			(
				SELECT 			
					c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID,
					c.value('(@sys)', 'INT') AS SYS_ID,
					c.value('(@net)', 'INT') AS NET_ID							
				FROM @xml.nodes('/root/item') AS a(c)
			) AS a
			INNER JOIN Tender.PriceSplit(@LIST, @MONTH, @SPREAD) b ON a.SYS_ID = b.SystemID AND a.NET_ID = b.DistrTypeID
END
