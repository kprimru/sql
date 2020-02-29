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

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

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
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END