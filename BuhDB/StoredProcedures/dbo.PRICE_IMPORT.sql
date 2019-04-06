USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRICE_IMPORT]
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
	
	UPDATE a
	SET SystemServicePrice = PRICE
	FROM
		dbo.SystemTable a
		INNER JOIN #price ON SYS = SystemReg
	WHERE SystemServicePrice <> PRICE
				
	EXEC sp_xml_removedocument @hdoc

	IF OBJECT_ID('tempdb..#price') IS NOT NULL
		DROP TABLE #price
		
	SELECT @RES AS RES
END
