﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[IP].[LogFileView]', 'V ') IS NULL EXEC('CREATE VIEW [IP].[LogFileView]  AS SELECT 1')
GO
ALTER VIEW [IP].[LogFileView]
AS
	SELECT F.[FL_NAME], L.[LF_TEXT], L.[LF_DISTR], L.[LF_COMP], L.[LF_SYS], L.[LF_DATE], S.[SRV_NAME]
	FROM [IPLogs].[dbo].[LogFiles]		AS L
	INNER JOIN [IPLogs].[dbo].[Files]	AS F ON F.[FL_ID] = L.[LF_ID_FILE]
	INNER JOIN [IPLogs].[dbo].[Servers] AS S ON S.[SRV_ID] = F.[FL_ID_SERVER]
	WHERE LF_TYPE = ''
GO
