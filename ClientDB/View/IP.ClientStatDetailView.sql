USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [IP].[ClientStatDetailView]
AS
	SELECT
		CSD_SYS, CSD_DISTR, CSD_COMP, CSD_ID,
		--ISNULL(CSD_START, CSD_END) AS CSD_DATE,
		CSD_START AS CSD_DATE,
		dbo.TimeSecToStr(CSD_DOWNLOAD_TIME) AS CSD_DOWNLOAD_TIME,
		dbo.TimeSecToStr(CSD_UPDATE_TIME) AS CSD_UPDATE_TIME,
		CSD_LOG_PATH, CSD_LOG_FILE, CSD_USR, CSD_ANS_SIZE, CSD_CACHE_SIZE,
		CONVERT(NVARCHAR(16), b.RC_NUM) + ' (' + b.RC_TEXT + ')' AS CLIENT_CODE, b.RC_ERROR AS CLIENT_CODE_ERROR,
		CONVERT(NVARCHAR(16), c.RC_NUM) + ' (' + c.RC_TEXT + ')' AS SERVER_CODE, c.RC_ERROR AS SERVER_CODE_ERROR,
		CASE
			WHEN CSD_STT_SEND = 1 AND CSD_STT_RESULT = 1 THEN '��'
			WHEN CSD_STT_SEND = 1 AND CSD_STT_RESULT = 0 THEN '��������'
			WHEN CSD_STT_SEND = 0 THEN '���'
			ELSE '����������'
		END AS STT_SEND,
		SRV_PATH + CSD_LOG_PATH + '\' + CSD_LOG_FILE AS CSD_LOG_FULL,
		SRV_PATH + 'Reports' + '\' + CSD_USR AS CSD_USR_FULL
	FROM
		[PC275-SQL\OMEGA].IPLogs.dbo.ClientStatDetail a
		LEFT JOIN [PC275-SQL\OMEGA].IPLogs.dbo.ReturnCode b ON a.CSD_CODE_CLIENT = b.RC_NUM AND b.RC_TYPE = 'CLIENT'
		LEFT JOIN [PC275-SQL\OMEGA].IPLogs.dbo.ReturnCode c ON a.CSD_CODE_SERVER = c.RC_NUM AND c.RC_TYPE = 'SERVER'
		INNER JOIN [PC275-SQL\OMEGA].IPLogs.dbo.ClientStat d ON a.CSD_ID_CS = d.CS_ID
		INNER JOIN [PC275-SQL\OMEGA].IPLogs.dbo.Files e ON e.FL_ID = d.CS_ID_FILE
		INNER JOIN [PC275-SQL\OMEGA].IPLogs.dbo.Servers f ON f.SRV_ID = e.FL_ID_SERVER
