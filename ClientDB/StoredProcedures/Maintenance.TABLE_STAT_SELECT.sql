USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Maintenance].[TABLE_STAT_SELECT]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

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
END