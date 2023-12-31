USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [USR].[USRIBDateView]
WITH SCHEMABINDING
AS
	SELECT UD_ID, UD_ID_CLIENT, UF_PATH, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE, UIU_DATE_S, UIU_DOCS, USRFileKindName, COUNT_BIG(*) AS CNT
	FROM
		USR.USRData
		INNER JOIN USR.USRFile ON UF_ID_COMPLECT = UD_ID
		INNER JOIN USR.USRIB ON UI_ID_USR = UF_ID
		INNER JOIN USR.USRUpdates ON UIU_ID_IB = UI_ID
		INNER JOIN dbo.USRFileKindTable ON USRFileKindID = UIU_ID_KIND
	WHERE UD_ID_CLIENT IS NOT NULL
	GROUP BY UD_ID, UD_ID_CLIENT, UF_PATH, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE, UIU_DATE_S, UIU_DOCS, USRFileKindName

GO
CREATE UNIQUE CLUSTERED INDEX [UC_USR.USRIBDateView+COL+INCL] ON [USR].[USRIBDateView] ([UIU_DATE_S] ASC, [UIU_DATE] ASC, [UD_ID_CLIENT] ASC, [UD_ID] ASC, [UF_PATH] ASC, [UI_COMP] ASC, [UI_DISTR] ASC, [UI_ID_BASE] ASC, [UIU_DOCS] ASC, [USRFileKindName] ASC);
CREATE NONCLUSTERED INDEX [IX_USR.USRIBDateView(UD_ID_CLIENT,UIU_DATE_S)+(UD_ID,USRFileKindName)] ON [USR].[USRIBDateView] ([UD_ID_CLIENT] ASC, [UIU_DATE_S] ASC) INCLUDE ([UD_ID], [USRFileKindName]);
CREATE NONCLUSTERED INDEX [IX_USR.USRIBDateView(UD_ID_CLIENT,UIU_DATE_S,UI_DISTR,UI_ID_BASE,UI_COMP)+INCL] ON [USR].[USRIBDateView] ([UD_ID_CLIENT] ASC, [UIU_DATE_S] ASC, [UI_DISTR] ASC, [UI_ID_BASE] ASC, [UI_COMP] ASC) INCLUDE ([UF_PATH], [UIU_DATE], [UIU_DOCS]);
GO
