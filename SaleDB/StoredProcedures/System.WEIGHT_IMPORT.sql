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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [System].[WEIGHT_IMPORT] TO rl_system_weight_import;
GO
