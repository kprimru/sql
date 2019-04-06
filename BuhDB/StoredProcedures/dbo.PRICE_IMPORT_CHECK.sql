USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRICE_IMPORT_CHECK]
	@DATA	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML
	DECLARE @HDOC INT
	
	IF OBJECT_ID('tempdb..#price') IS NOT NULL
		DROP TABLE #price

	CREATE TABLE #price
		(
			SYS		NVARCHAR(64),			
			PRICE	MONEY
		)
			
	SET @XML = CAST(@DATA AS XML)

	EXEC sp_xml_preparedocument @HDOC OUTPUT, @XML

	INSERT INTO #price(SYS, PRICE)
		SELECT
			c.value('@SYS', 'NVARCHAR(64)'),
			c.value('@PRICE', 'MONEY')
		FROM @XML.nodes('/ROOT/*') AS a(c)
			
	DECLARE @RES NVARCHAR(MAX)
	
	SET @RES = ''
	
	SELECT @RES = @RES + SystemName + ': с ' + dbo.MoneyFormat(SystemServicePrice) + ' на ' + dbo.MoneyFormat(PRICE) + CHAR(10)
	FROM
		(
			SELECT SystemOrder, SystemGroupOrder, SystemName, SystemServicePrice, PRICE
			FROM
				#price
				INNER JOIN dbo.SystemTable a ON SYS = SystemReg				
				INNER JOIN dbo.SystemGroupTable b ON a.SystemGroupID = b.SystemGroupID
			WHERE SystemServicePrice <> PRICE
		) AS o_O
	ORDER BY SystemGroupOrder, SystemOrder
		
	EXEC sp_xml_removedocument @hdoc

	IF OBJECT_ID('tempdb..#price') IS NOT NULL
		DROP TABLE #price
		
	SELECT @RES AS RES
END
