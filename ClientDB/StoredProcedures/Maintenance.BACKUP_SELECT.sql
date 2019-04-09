USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[BACKUP_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	/*
	SELECT TOP 100 physical_device_name AS BCKP_PATH, backup_finish_date AS BCKP_DATE, dbo.FileByteSizeToStr(backup_size) AS BCKP_SIZE
	FROM 
		msdb.dbo.backupset AS bkps 
		INNER JOIN msdb.dbo.backupmediafamily bkmf ON bkps.media_set_id = bkmf.media_set_id 
	WHERE database_name = DB_NAME() AND type = 'D'
	ORDER BY backup_finish_date DESC
	*/
	
	
	IF OBJECT_ID('tempdb..#bckp') IS NOT NULL
		DROP TABLE #bckp
	
	CREATE TABLE #bckp
		(
			ID			INT IDENTITY(1, 1),
			BCKP_PATH	NVARCHAR(512), 
			BCKP_DATE	DATETIME, 
			BCKP_SIZE	BIGINT
		)
	
	INSERT INTO #bckp(BCKP_PATH, BCKP_DATE, BCKP_SIZE)	
		SELECT TOP 100 physical_device_name, backup_finish_date, backup_size
		FROM 
			msdb.dbo.backupset AS bkps 
			INNER JOIN msdb.dbo.backupmediafamily bkmf ON bkps.media_set_id = bkmf.media_set_id 
		WHERE database_name = DB_NAME() AND type = 'D'
		ORDER BY backup_finish_date DESC
	
	SELECT 
		BCKP_PATH, BCKP_DATE, BCKP_SIZE, dbo.FileByteSizeToStr(BCKP_SIZE) AS BCKP_SIZE_STR, 
		dbo.FileByteSizeToStr(BCKP_SIZE - 
				(
					SELECT BCKP_SIZE
					FROM #bckp b
					WHERE a.ID = b.ID - 1
				)
			) AS BCKP_SIZE_DELTA
	FROM #bckp a
	ORDER BY BCKP_DATE DESC
	
	IF OBJECT_ID('tempdb..#bckp') IS NOT NULL
		DROP TABLE #bckp
END