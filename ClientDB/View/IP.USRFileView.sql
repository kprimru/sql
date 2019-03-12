USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [IP].[USRFileView]
AS
	SELECT FL_NAME, UF_USR_DATA, UF_DATE, UF_SYS, UF_DISTR, UF_COMP, UF_USR_NAME
	FROM 
		[PC275-SQL\OMEGA].IPLogs.dbo.USRFiles a
		INNER JOIN [PC275-SQL\OMEGA].IPLogs.dbo.Files b ON a.UF_ID_FILE = b.FL_ID