USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRICE_IMPORT_CHECK]
	@TYPE	SMALLINT,
	@PERIOD	SMALLINT,
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
		
		SELECT @RES = @RES + SYS_SHORT_NAME + ': с ' + dbo.MoneyFormat(PS_PRICE) + ' на ' + dbo.MoneyFormat(PRICE) + '	'--CHAR(10)
		FROM
			(
				SELECT SYS_ORDER, SYS_SHORT_NAME, PS_PRICE, PRICE
				FROM
					#price
					INNER JOIN dbo.SystemTable ON SYS = SYS_REG_NAME
					INNER JOIN dbo.PriceSystemTable ON PS_ID_SYSTEM = SYS_ID 
													AND PS_ID_TYPE = @TYPE 
													AND PS_ID_PERIOD = @PERIOD
				WHERE PS_PRICE <> PRICE
			) AS o_O
		ORDER BY SYS_ORDER
			
		EXEC sp_xml_removedocument @hdoc

		IF OBJECT_ID('tempdb..#price') IS NOT NULL
			DROP TABLE #price
			
		SELECT @RES AS RES
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
