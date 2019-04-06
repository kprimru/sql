USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[BAKUP_SELECT]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 1 
		physical_device_name, backup_finish_date, 
		dbo.FileByteSizeToStr(backup_size) AS backup_size
	FROM 
		msdb.dbo.backupset AS bkps 
		INNER JOIN msdb.dbo.backupmediafamily bkmf ON bkps.media_set_id = bkmf.media_set_id 
    WHERE database_name = DB_NAME() AND type = 'D'
    ORDER BY backup_finish_date DESC
END