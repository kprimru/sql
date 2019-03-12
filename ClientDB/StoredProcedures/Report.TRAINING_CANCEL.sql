USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Report].[TRAINING_CANCEL]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	/*
	SELECT ClientFullName AS [Клиент], ManagerName AS [Рук-ль], ServiceName AS [СИ], COUNT(DISTINCT SP_ID) AS [Сколько раз], MAX(TSC_DATE) AS [Последний раз]
	FROM 
		Training.TrainingSchedule
		INNER JOIN Training.SeminarSign ON SP_ID_SEMINAR = TSC_ID
		INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
		INNER JOIN dbo.ClientView WITH(NOEXPAND) ON SP_ID_CLIENT = ClientID
	WHERE SSP_CANCEL = 1
	GROUP BY ClientFullname, ManagerName, ServiceName
	HAVING COUNT(DISTINCT SP_ID) > 2
	ORDER BY [Сколько раз] DESC, ManagerName, ServiceName, ClientFullName
	*/
	
	--Этот отчет по новой структуре записи на семинар. Есть мнение, что в новую структуру попали не все исторические данные, так что пока менять отчет рано
	
	SELECT ClientFullName AS [Клиент], ManagerName AS [Рук-ль], ServiceName AS [СИ], COUNT(DISTINCT ID_SCHEDULE) AS [Сколько раз], MAX(c.DATE) AS [Последний раз]
	FROM 
		Seminar.Personal a
		INNER JOIN Seminar.Status b ON a.ID_STATUS = b.ID
		INNER JOIN Seminar.Schedule c ON c.ID = a.ID_SCHEDULE
		INNER JOIN dbo.ClientView WITH(NOEXPAND) ON a.ID_CLIENT = ClientID
	WHERE b.INDX = 5 AND a.STATUS = 1
	GROUP BY ClientFullname, ManagerName, ServiceName
	HAVING COUNT(DISTINCT ID_SCHEDULE) > 2
	ORDER BY [Сколько раз] DESC, ManagerName, ServiceName, ClientFullName	
	
END
