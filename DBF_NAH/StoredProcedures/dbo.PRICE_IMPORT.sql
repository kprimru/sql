USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_IMPORT]
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

		UPDATE a
		SET PS_PRICE = PRICE
		FROM
			dbo.PriceSystemTable a
			INNER JOIN dbo.SystemTable ON PS_ID_SYSTEM = SYS_ID
			INNER JOIN #price ON SYS = SYS_REG_NAME
		WHERE PS_ID_TYPE = @TYPE
			AND PS_ID_PERIOD = @PERIOD
			AND PS_PRICE <> PRICE

		INSERT INTO dbo.PriceSystemTable(PS_ID_TYPE, PS_ID_SYSTEM, PS_ID_PERIOD, PS_PRICE)
			SELECT @TYPE, SYS_ID, @PERIOD, PRICE
			FROM
				#price
				INNER JOIN dbo.SystemTable ON SYS = SYS_REG_NAME
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.PriceSystemTable
					WHERE PS_ID_PERIOD = @PERIOD
						AND PS_ID_SYSTEM = SYS_ID
						AND PS_ID_TYPE = @TYPE
				)

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

GO
GRANT EXECUTE ON [dbo].[PRICE_IMPORT] TO rl_price_list_w;
GRANT EXECUTE ON [dbo].[PRICE_IMPORT] TO rl_price_w;
GO
