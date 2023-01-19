﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[DatabaseSize]', 'IF') IS NULL EXEC('CREATE FUNCTION [Maintenance].[DatabaseSize] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [Maintenance].[DatabaseSize]()
RETURNS TABLE
AS
RETURN
(
	SELECT
		schemaname + '.' + tablename AS obj_name,
		row_count, reserved, reserved_str, data, data_str, index_size, index_str, unused, unused_str
	FROM
		(
			SELECT
				a3.name AS [schemaname],
				a2.name AS [tablename],
				a1.rows as row_count,
				(a1.reserved + ISNULL(a4.reserved,0))* 8 * 1024 AS reserved,
				dbo.FileByteSizeToStr((a1.reserved + ISNULL(a4.reserved,0))* 8 * 1024) AS reserved_str,
				a1.data * 8 * 1024 AS data,
				dbo.FileByteSizeToStr(a1.data * 8 * 1024) AS data_str,
				(
					CASE
						WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data
						ELSE 0
					END
				) * 8 * 1024 AS index_size,
				(
					CASE
						WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN  dbo.FileByteSizeToStr(((a1.used + ISNULL(a4.used,0)) - a1.data) * 8 * 1024)
						ELSE '0 б'
					END
				)  AS index_str,
				(
					CASE
						WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used
						ELSE 0
					END
				) * 8 * 1024 AS unused,
				(
					CASE
						WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN dbo.FileByteSizeToStr(((a1.reserved + ISNULL(a4.reserved,0)) - a1.used) * 8 * 1024)
						ELSE '0 б'
					END
				) AS unused_str
			FROM
				(
					SELECT
						ps.object_id,
						SUM (
							CASE
								WHEN (ps.index_id < 2) THEN row_count
								ELSE 0
							END
						) AS [rows],
						SUM (ps.reserved_page_count) AS reserved,
						SUM (
							CASE
								WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
								ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
							END
						) AS data,
						SUM (ps.used_page_count) AS used
					FROM sys.dm_db_partition_stats ps
					GROUP BY ps.object_id
				) AS a1
				LEFT OUTER JOIN	(
					SELECT
						it.parent_id,
						SUM(ps.reserved_page_count) AS reserved,
						SUM(ps.used_page_count) AS used
					FROM sys.dm_db_partition_stats ps
						INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
					WHERE it.internal_type IN (202,204)
					GROUP BY it.parent_id
				) AS a4 ON (a4.parent_id = a1.object_id)
				INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id )
				INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
			WHERE a2.type <> N'S' and a2.type <> N'IT'
		) AS dt
)
GO
