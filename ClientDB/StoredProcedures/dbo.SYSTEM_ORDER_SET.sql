USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SYSTEM_ORDER_SET]
	@DATA	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @xml XML
	DECLARE @hdoc INT
	
	IF OBJECT_ID('tempdb..#sys') IS NOT NULL
		DROP TABLE #sys

	CREATE TABLE #sys
		(				
			SYS_ID INT,
			SYS_ORDER INT
		)
			
	SET @xml = CAST(@DATA AS XML)

	EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml

	INSERT INTO #sys(SYS_ID, SYS_ORDER)
		SELECT DISTINCT
			c.value('(@ID)', 'INT'),
			c.value('(@ORDER)', 'INT')
		FROM @xml.nodes('/ROOT/*') AS a(c)

	
	UPDATE dbo.SystemTable
	SET SystemOrder = (SELECT TOP 1 SYS_ORDER FROM #sys WHERE SYS_ID = SystemID ORDER BY SYS_ORDER)

	EXEC sp_xml_removedocument @hdoc

	IF OBJECT_ID('tempdb..#sys') IS NOT NULL
		DROP TABLE #sys
END