USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientSeminarDateView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientSeminarDateView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientSeminarDateView]
WITH SCHEMABINDING
AS
	SELECT
		a.ID_CLIENT, a.DATE, COUNT_BIG(*) AS CNT
	FROM
		dbo.ClientStudy a
		INNER JOIN dbo.ClientStudyPeople b ON a.ID = b.ID_STUDY
	WHERE ID_PLACE = 3 AND STATUS = 1
	GROUP BY ID_CLIENT, DATE
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientSeminarDateView(ID_CLIENT,DATE)] ON [dbo].[ClientSeminarDateView] ([ID_CLIENT] ASC, [DATE] ASC);
GO
