USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INFO_BANK_ORDER_SET]
	@DATA	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @xml XML
	DECLARE @hdoc INT
	
	IF OBJECT_ID('tempdb..#ib') IS NOT NULL
		DROP TABLE #ib

	CREATE TABLE #ib
		(				
			IB_ID INT,
			IB_ORDER INT
		)
			
	SET @xml = CAST(@DATA AS XML)

	EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml

	INSERT INTO #ib(ID_ID, IB_ORDER)
		SELECT ID, MAX(ORD)
		FROM
			(
				SELECT DISTINCT
					c.value('(@ID)', 'INT') AS ID,
					c.value('(@ORDER)', 'INT') AS ORD
				FROM @xml.nodes('/ROOT/*') AS a(c)
			) AS o_O
		GROUP BY ID

	
	UPDATE dbo.InfoBankTable
	SET InfoBankOrder = (SELECT TOP 1 IB_ORDER FROM #ib WHERE IB_ID = InfoBankID ORDER BY IB_ORDER)

	EXEC sp_xml_removedocument @hdoc

	IF OBJECT_ID('tempdb..#ib') IS NOT NULL
		DROP TABLE #ib
END