USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [System].[PRICE_IMPORT]
	@DATA	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		DECLARE @XML XML
		DECLARE @HDOC INT

		IF OBJECT_ID('tempdb..#price') IS NOT NULL
			DROP TABLE #price

		CREATE TABLE #price
			(
				SYS		NVARCHAR(64),
				DATE	SMALLDATETIME,
				PRICE	MONEY
			)

		SET @XML = CAST(@DATA AS XML)

		EXEC sp_xml_preparedocument @HDOC OUTPUT, @XML

		INSERT INTO #price(SYS, DATE, PRICE)
			SELECT
				c.value('@SYS', 'NVARCHAR(64)'),
				c.value('@DATE', 'SMALLDATETIME'),
				c.value('@PRICE', 'MONEY')
			FROM @XML.nodes('/ROOT/*') AS a(c)

		INSERT INTO System.Price(ID_MONTH, ID_SYSTEM, PRICE)
			SELECT c.ID, b.ID, a.PRICE
			FROM
				#price a
				INNER JOIN System.Systems b ON a.SYS = b.REG
				INNER JOIN Common.Month c ON c.DATE = a.DATE
		WHERE NOT EXISTS
			(
				SELECT *
				FROM System.Price
				WHERE ID_MONTH = c.ID AND ID_SYSTEM = b.ID
			)

		EXEC sp_xml_removedocument @hdoc

		IF OBJECT_ID('tempdb..#price') IS NOT NULL
			DROP TABLE #price

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [System].[PRICE_IMPORT] TO rl_price_import;
GO
