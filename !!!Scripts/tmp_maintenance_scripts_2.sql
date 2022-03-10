SELECT TOP 10
       [Average Time Blocked] = (total_elapsed_time - total_worker_time) / qs.execution_count,
       [Total Time Blocked] = total_elapsed_time - total_worker_time,
       [Execution count] = qs.execution_count,
       [Individual Query] = SUBSTRING (qt.text,qs.statement_start_offset/2, 
         (CASE
            WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
            ELSE qs.statement_end_offset
          END - qs.statement_start_offset)/2),
       [Parent Query] = qt.text,
       [DatabaseName] = DB_NAME(qt.dbid)
  FROM sys.dm_exec_query_stats qs
  CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
  ORDER BY [Average Time Blocked] DESC;


select top 5 
    (total_logical_reads/execution_count) as avg_logical_reads,
    (total_logical_writes/execution_count) as avg_logical_writes,
    (total_physical_reads/execution_count) as avg_phys_reads,
     Execution_count, 
    statement_start_offset as stmt_start_offset, 
    plan_handle,
    qt.text
from sys.dm_exec_query_stats  qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
order by  (total_logical_reads + total_logical_writes) Desc


SELECT t.name AS [TableName],
       fi.page_count AS [Pages],
       fi.record_count AS [Rows],
       CAST(fi.avg_record_size_in_bytes AS int) AS [AverageRecordBytes],
       CAST(fi.avg_fragmentation_in_percent AS int) AS [AverageFragmentationPercent],
       SUM(iop.leaf_insert_count) AS [Inserts],
       SUM(iop.leaf_delete_count) AS [Deletes],
       SUM(iop.leaf_update_count) AS [Updates],
       SUM(iop.row_lock_count) AS [RowLocks],
       SUM(iop.page_lock_count) AS [PageLocks]
  FROM sys.dm_db_index_operational_stats(DB_ID(),NULL,NULL,NULL) AS iop
  JOIN sys.indexes AS i ON iop.index_id = i.index_id AND
                           iop.object_id = i.object_id
  JOIN sys.tables AS t ON i.object_id = t.object_id AND
                          i.type_desc IN ('CLUSTERED', 'HEAP')
  JOIN sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') AS fi ON fi.object_id=CAST(t.object_id AS int) AND
                                                                                     fi.index_id=CAST(i.index_id AS int)
  GROUP BY t.name, fi.page_count, fi.record_count, fi.avg_record_size_in_bytes, fi.avg_fragmentation_in_percent
  ORDER BY [RowLocks] desc
  
  
  -- i/o-нагрузка на файлы
SELECT TOP 10 DB_NAME(saf.dbid) AS [База данных],
       saf.name AS [Логическое имя],
       vfs.BytesRead/1048576 AS [Прочитано (Мб)],
       vfs.BytesWritten/1048576 AS [Записано (Мб)],
       saf.filename AS [Путь к файлу]
  FROM master..sysaltfiles AS saf
  JOIN ::fn_virtualfilestats(NULL,NULL) AS vfs ON vfs.dbid = saf.dbid AND
                                                  vfs.fileid = saf.fileid AND
                                                  saf.dbid NOT IN (1,3,4)
  ORDER BY vfs.BytesRead/1048576 + BytesWritten/1048576 DESC
  
  -- i/o-нагрузка на диски
SELECT SUBSTRING(saf.physical_name, 1, 1)    AS [Диск],
       SUM(vfs.num_of_bytes_read/1048576)    AS [Прочитано (Мб)],
       SUM(vfs.num_of_bytes_written/1048576) AS [Записано (Мб)]
  FROM sys.master_files AS saf
  JOIN sys.dm_io_virtual_file_stats(NULL,NULL) AS vfs ON vfs.database_id = saf.database_id AND
                                                         vfs.file_id = saf.file_id AND
                                                         saf.database_id NOT IN (1,3,4) AND
                                                         saf.type < 2
  GROUP BY SUBSTRING(saf.physical_name, 1, 1)
  ORDER BY [Диск]