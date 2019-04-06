USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[SERVICE_GRAPH]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ManagerName AS [Руководитель], ServiceName AS [СИ], CL_CNT AS [Кол-во клиентов], AVG_TIME AS [Среднее время у клиента],
		dbo.TimeMinToStr(TOTAL_TIME) AS [Общее время в неделю]
	FROM
		(
			SELECT ManagerName, ServiceName, COUNT(*) AS CL_CNT, AVG(ServiceTime) AS AVG_TIME, SUM(ServiceTime) AS TOTAL_TIME
			FROM 
				dbo.ClientTable a
				INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
				INNER JOIN dbo.ManagerTable c ON b.ManagerID = c.ManagerID
			WHERE StatusID = 2 AND a.STATUS = 1
			GROUP BY ManagerName, ServiceName
		) AS o_O
	ORDER BY ManagerName, ServiceName
END
