USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [USR].[USRFileView]
WITH SCHEMABINDING
AS
	SELECT UD_ID, UD_ID_CLIENT, UF_ID, UF_DATE, UF_PATH, USRFileKindName, dbo.DateOf(UF_DATE) AS UF_DATE_S
	FROM
		USR.USRData
		INNER JOIN USR.USRFile ON UF_ID_COMPLECT = UD_ID
		INNER JOIN dbo.USRFileKindTable ON USRFileKindID = UF_ID_KIND
	WHERE UD_ID_CLIENT IS NOT NULL

GO
CREATE UNIQUE CLUSTERED INDEX [UC_USR.USRFileView(UF_ID)] ON [USR].[USRFileView] ([UF_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_USR.USRFileView(UD_ID_CLIENT,UF_DATE_S)+(UD_ID,UF_PATH,USRFileKindName)] ON [USR].[USRFileView] ([UD_ID_CLIENT] ASC, [UF_DATE_S] ASC) INCLUDE ([UD_ID], [UF_PATH], [USRFileKindName]);
GO
