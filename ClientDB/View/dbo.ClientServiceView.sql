USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientServiceView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientServiceView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientServiceView]
AS
	SELECT ID_CLIENT, ID_SERVICE, DATE AS START, DATEADD(YEAR, 10, dbo.DateOf(GETDATE())) AS FINISH
	FROM dbo.ClientService
	WHERE STATUS = 1

	UNION

	SELECT
		ID_CLIENT, ID_SERVICE,
			DATE AS START,
			(
				SELECT TOP 1 DATEADD(DAY, -1, DATE)
				FROM dbo.ClientService b
				WHERE a.ID_CLIENT = b.ID_CLIENT
					AND b.UPD_DATE > a.UPD_DATE
				ORDER BY UPD_DATE
			) AS FINISH
	FROM dbo.ClientService a
	WHERE STATUS <> 1
		AND EXISTS
			(
				SELECT *
				FROM dbo.ClientService b
				WHERE a.ID_CLIENT = b.ID_CLIENT
					AND b.UPD_DATE > a.UPD_DATE
			)GO
