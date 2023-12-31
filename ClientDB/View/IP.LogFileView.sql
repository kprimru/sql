USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [IP].[LogFileView]
AS
	SELECT FL_NAME, LF_TEXT, LF_DISTR, LF_COMP, LF_SYS, LF_DATE
	FROM
		[PC275-SQL\OMEGA].IPLogs.dbo.LogFiles a
		INNER JOIN [PC275-SQL\OMEGA].IPLogs.dbo.Files b ON a.LF_ID_FILE = b.FL_ID
	WHERE LF_TYPE = ''
GO
