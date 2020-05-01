USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Maintenance].[TABLE_STAT_SELECT]
WITH EXECUTE AS OWNER
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

		SELECT
			'[' + OBJECT_SCHEMA_NAME(a.object_id) + '].[' + OBJECT_NAME(a.object_id) + ']' AS tbl_name,
			MAX(STATS_DATE(a.object_id, b.index_id)) stat_date,
			DATEDIFF(DAY, MAX(STATS_DATE(a.object_id, b.index_id)), GETDATE()) AS stat_delta
		FROM
			sys.tables a
			INNER JOIN	sys.indexes b ON a.object_id = b.object_id
		WHERE b.name is not null and a.name <> 'sysdiagrams' and a.name <> 'dtproperties'
		GROUP BY a.object_id
		ORDER BY OBJECT_SCHEMA_NAME(a.object_id), OBJECT_NAME(a.object_id)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Maintenance].[TABLE_STAT_SELECT] TO rl_maintenance;
GO