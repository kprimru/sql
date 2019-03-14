USE [IPLogs]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[ClientStatView]
WITH SCHEMABINDING
AS
	SELECT 
		CSD_MONTH, CSD_DAY, FL_ID_SERVER,
		SUM(CSD_QST_SIZE) AS CSD_QST_SIZE,
		SUM(CSD_ANS_SIZE) AS CSD_ANS_SIZE,
		SUM(CSD_CACHE_SIZE) AS CSD_CACHE_SIZE,
		SUM(CSD_REPORT_SIZE) AS CSD_REPORT_SIZE,
		COUNT_BIG(*) AS CNT
	FROM 
		dbo.ClientStatDetail
		INNER JOIN dbo.ClientStat ON CS_ID = CSD_ID_CS
		INNER JOIN dbo.Files  ON FL_ID = CS_ID_FILE			
	GROUP BY CSD_MONTH, CSD_DAY, FL_ID_SERVER
