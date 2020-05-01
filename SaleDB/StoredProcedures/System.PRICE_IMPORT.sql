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
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GRANT EXECUTE ON [System].[PRICE_IMPORT] TO rl_price_import;
GO