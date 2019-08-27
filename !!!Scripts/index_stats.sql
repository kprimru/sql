SELECT 
	[Рекомендуемый индекс]= 
			'CREATE INDEX [IX_' + OBJECT_SCHEMA_NAME(mid.object_id) + '.' + OBJECT_NAME(mid.object_id) + '(' +
		replace(
			replace(
				replace(
					ISNULL(mid.equality_columns,'')
					+
					ISNULL(CASE WHEN mid.equality_columns IS NULL THEN '' ELSE ', ' END + mid.inequality_columns, ''), 
					'[', ''), 
				']', ''), 
			', ', ',')
		+ '] ON '
		+ Replace(mid.statement, '[' + DB_NAME() + '].', '')
		+ ' (' + ISNULL(mid.equality_columns,'')
		+ case when mid.equality_columns is not null
					and mid.inequality_columns is not null then ', '
				else ''
				end
		+ ISNULL(mid.inequality_columns,'') + 
		')' + ISNULL(' INCLUDE (' + mid.included_columns + ')','') + ';'
	, [Число компиляций] = migs.unique_compiles
	, [Количество операций поиска] = migs.user_seeks
	, [Количество операций просмотра] = migs.user_scans
	, [Средняя стоимость ] = CAST(migs.avg_total_user_cost AS int)
	, [Средний процент выигрыша] = CAST(migs.avg_user_impact AS int)
FROM sys.dm_db_missing_index_groups				mig
INNER JOIN sys.dm_db_missing_index_group_stats	migs	ON	migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details		mid		ON	mig.index_handle = mid.index_handle
WHERE mid.database_id = DB_ID()
ORDER BY OBJECT_SCHEMA_NAME(mid.object_id), OBJECT_NAME(mid.object_id), mid.equality_columns, mid.inequality_columns














SELECT  OBJECT_SCHEMA_NAME(i.object_id) AS [Schema Name] ,
		OBJECT_NAME(i.object_id) AS [Table Name],
         i.name AS [Not Used Index Name],
         s.last_user_update AS [Last Update Time],
         s.user_updates AS [Updates]
FROM     sys.dm_db_index_usage_stats AS s
JOIN     sys.indexes AS i
ON       i.object_id = s.object_id
AND      i.index_id = s.index_id
JOIN     sys.objects AS o
ON       o.object_id = s.object_id
WHERE    s.database_id = DB_ID()
AND      (    user_scans   = 0
          AND user_seeks   = 0
          AND user_lookups = 0
          AND last_user_scan   IS NULL
          AND last_user_seek   IS NULL
          AND last_user_lookup IS NULL 
         )
AND      OBJECTPROPERTY(i.[object_id],         'IsSystemTable'   ) = 0
AND      INDEXPROPERTY (i.[object_id], i.name, 'IsAutoStatistics') = 0
AND      INDEXPROPERTY (i.[object_id], i.name, 'IsHypothetical'  ) = 0
AND      INDEXPROPERTY (i.[object_id], i.name, 'IsStatistics'    ) = 0
AND      INDEXPROPERTY (i.[object_id], i.name, 'IsFulltextKey'   ) = 0
AND      (i.index_id between 2 AND 250 OR (i.index_id=1 AND OBJECTPROPERTY(i.[object_id],'IsView')=1))
AND      o.type <> 'IT'
ORDER BY OBJECT_SCHEMA_NAME(i.object_id), OBJECT_NAME(i.object_id)