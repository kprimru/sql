USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [USR].[USRFileView]
WITH SCHEMABINDING
AS
	SELECT UD_ID, UD_ID_CLIENT, UF_ID, UF_DATE, UF_PATH, USRFileKindName, dbo.DateOf(UF_DATE) AS UF_DATE_S
	FROM
		USR.USRData 
		INNER JOIN USR.USRFile ON UF_ID_COMPLECT = UD_ID
		INNER JOIN dbo.USRFileKindTable ON USRFileKindID = UF_ID_KIND
	WHERE UD_ID_CLIENT IS NOT NULL
