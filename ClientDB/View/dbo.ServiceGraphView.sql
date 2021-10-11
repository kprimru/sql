USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ServiceGraphView]
AS
	SELECT
		a.ORD,
		a.ClientID, ClientServiceID, ClientFullname,
		ServiceStart, ServiceTime, DayOrder, ClientFullname AS ClientShortName,
		CASE
			WHEN ServiceTime < 10 THEN 'Ќеверна€ продолжительность работы (не может быть меньше 10 минут)'
			WHEN ORD > 1 AND
				DATEDIFF(MINUTE,
					(
						SELECT DATEADD(MINUTE, b.ServiceTime, b.ServiceStart)
						FROM
							(
								SELECT
									ROW_NUMBER() OVER(PARTITION BY z.ClientServiceID ORDER BY t.DayOrder, z.ServiceStart, z.ServiceTime, z.ClientFullName) AS ORD,
									z.ClientID, z.ServiceStart, z.ServiceTime, t.DayOrder, z.ClientServiceID
								FROM
									dbo.ClientTable z
									INNER JOIN [dbo].[ServiceStatusConnected]() s ON z.StatusId = s.ServiceStatusId
									INNER JOIN dbo.DayTable t ON t.DayID = z.DayID
								WHERE z.STATUS = 1
									AND z.ClientServiceID = a.ClientServiceID
							) b
						WHERE b.ORD = a.ORD - 1 AND a.DayOrder = b.DayOrder
					), a.ServiceStart) < 0
				THEN 'ѕересечение'
			ELSE NULL
		END AS GR_ERROR
	FROM
		(
			SELECT
				ClientID,
				ROW_NUMBER() OVER(PARTITION BY ClientServiceID ORDER BY DayOrder, ServiceStart, ServiceTime, ClientFullName) AS ORD,
				ClientFullName, ServiceStart, ServiceTime, DayOrder, ClientServiceID, ClientShortName
			FROM
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN dbo.DayTable e ON e.DayID = a.DayID
			WHERE a.STATUS = 1
				AND ServiceStart IS NOT NULL
				AND ServiceTime IS NOT NULL
		) AS a
GO
