SELECT count(*)AS cached_pages_count, count(*)/128  'Size (Mb)'
    ,CASE database_id
        WHEN 32767 THEN 'ResourceDb'
        ELSE db_name(database_id)
        END AS Database_name
FROM sys.dm_os_buffer_descriptors
GROUP BY db_name(database_id) ,database_id
ORDER BY cached_pages_count DESC

SELECT SUM([Size (Mb)])
FROM
	(
		SELECT count(*)AS cached_pages_count, count(*)/128  'Size (Mb)'
			,CASE database_id
				WHEN 32767 THEN 'ResourceDb'
				ELSE db_name(database_id)
				END AS Database_name
		FROM sys.dm_os_buffer_descriptors
		GROUP BY db_name(database_id) ,database_id
	) AS o_O