USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[TABLE_INDEX_SELECT]
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
			b.name, avg_fragmentation_in_percent, page_count, dbo.FileByteSizeToStr(CONVERT(BIGINT, page_count) * CONVERT(BIGINT, 8) * CONVERT(BIGINT, 1024)) AS index_size
		FROM 
			(
				SELECT object_id
				FROM sys.tables 
				
				UNION ALL

				SELECT object_id
				FROM sys.views
			) AS a INNER JOIN
			sys.indexes b ON a.object_id = b.object_id INNER JOIN
			sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'LIMITED') AS c ON c.object_id = b.object_id AND c.index_id = b.index_id
		WHERE b.name IS NOT NULL
		ORDER BY OBJECT_SCHEMA_NAME(a.object_id), OBJECT_NAME(a.object_id)
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END