USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[REPORT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[REPORT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[REPORT_SELECT]
	@NAME	NVARCHAR(512) = NULL
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

		IF OBJECT_ID('tempdb..#rep') IS NOT NULL
			DROP TABLE #rep

		CREATE TABLE #rep
			(
				ID			UNIQUEIDENTIFIER PRIMARY KEY
			)

		;WITH child_to_parents AS
			(
				SELECT ID, ID_MASTER
				FROM Report.Reports
				WHERE @NAME IS NULL
					OR NAME LIKE @NAME
					OR NOTE LIKE @NAME

				UNION ALL

				SELECT a.ID, a.ID_MASTER
				FROM
					Report.Reports a
					INNER JOIN child_to_parents b ON a.ID = b.ID_MASTER
			)
			INSERT INTO #rep(ID)
				SELECT DISTINCT ID
				FROM child_to_parents

		;WITH parents_to_child AS
			(
				SELECT ID, ID_MASTER
				FROM Report.Reports
				WHERE @NAME IS NULL
					OR NAME LIKE @NAME
					OR NOTE LIKE @NAME

				UNION ALL

				SELECT a.ID, a.ID_MASTER
				FROM
					Report.Reports a
					INNER JOIN parents_to_child b ON a.ID_MASTER = b.ID
			)
		INSERT INTO #rep(ID)
			SELECT ID
			FROM parents_to_child a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #rep b
					WHERE a.ID = b.ID
						--AND a.ID_PARENT = b.ID_PARENT
				)

		SELECT a.ID, ID_MASTER, NAME, NOTE, REP_SCHEMA, REP_PROC, SHORT
		FROM
			#rep a
			INNER JOIN Report.Reports b ON a.ID = b.ID
		ORDER BY NAME

		IF OBJECT_ID('tempdb..#rep') IS NOT NULL
			DROP TABLE #rep

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[REPORT_SELECT] TO rl_report;
GO
