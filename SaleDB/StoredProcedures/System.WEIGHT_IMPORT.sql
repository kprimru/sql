USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [System].[WEIGHT_IMPORT]
	@DATA	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @XML XML
		DECLARE @HDOC INT

		IF OBJECT_ID('tempdb..#weight') IS NOT NULL
			DROP TABLE #weight

		CREATE TABLE #weight
			(
				SYS		NVARCHAR(64),
				DATE	SMALLDATETIME,
				WEIGHT	DECIMAL(8, 4),
				PROBLEM	DECIMAL(8, 4)
			)

		SET @XML = CAST(@DATA AS XML)

		EXEC sp_xml_preparedocument @HDOC OUTPUT, @XML

		INSERT INTO #weight(SYS, DATE, WEIGHT, PROBLEM)
			SELECT
				c.value('@SYS', 'NVARCHAR(64)'),
				c.value('@DATE', 'SMALLDATETIME'),
				c.value('@WEIGHT', 'DECIMAL(8, 4)'),
				c.value('@PROBLEM', 'DECIMAL(8, 4)')
			FROM @XML.nodes('/ROOT/*') AS a(c)

		UPDATE z
		SET VALUE = WEIGHT,
			PROB_VALUE = PROBLEM
		FROM
			#weight a
			INNER JOIN System.Systems b ON a.SYS = b.REG
			INNER JOIN Common.Month c ON c.DATE = a.DATE
			INNER JOIN System.Weight z ON z.ID_MONTH = c.ID AND z.ID_SYSTEM = b.ID
		WHERE ISNULL(VALUE, 0) <> ISNULL(WEIGHT, 0)
			OR ISNULL(PROB_VALUE, 0) <> ISNULL(PROBLEM, 0)

		INSERT INTO System.Weight(ID_MONTH, ID_SYSTEM, VALUE, PROB_VALUE)
			SELECT c.ID, b.ID, a.WEIGHT, a.PROBLEM
			FROM
				#weight a
				INNER JOIN System.Systems b ON a.SYS = b.REG
				INNER JOIN Common.Month c ON c.DATE = a.DATE
		WHERE NOT EXISTS
			(
				SELECT *
				FROM System.Weight
				WHERE ID_MONTH = c.ID AND ID_SYSTEM = b.ID
			)

		EXEC sp_xml_removedocument @hdoc

		IF OBJECT_ID('tempdb..#weight') IS NOT NULL
			DROP TABLE #weight
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
GRANT EXECUTE ON [System].[WEIGHT_IMPORT] TO rl_system_weight_import;
GO