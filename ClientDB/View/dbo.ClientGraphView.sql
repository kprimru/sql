USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientGraphView]
AS
	SELECT 
		ID, ClientID, ClientServiceID, ClientFullName,
		CASE
			WHEN ServiceStart IS NULL THEN '�� ������� ����� ������ ������'
			WHEN ServiceTime IS NULL THEN '�� ������� ����������������� ������'
			WHEN ServiceTime < 10 THEN '�������� ����������������� ������ (�� ����� ���� ������ 10 �����)'
			WHEN DATEPART(HOUR, ServiceStart) = 0 THEN '�������� ����� ������ ������'
			WHEN ID > 1 AND
				DATEDIFF(MINUTE, 
					(						
						SELECT DATEADD(MINUTE, ServiceTime, ServiceStart)
						FROM 
							(
								SELECT 
									ROW_NUMBER() OVER(PARTITION BY ClientServiceID ORDER BY DayOrder, ServiceStart, ServiceTime, ClientFullName) AS ID, 
									ClientID, ClientFullName, ServiceStart, ServiceTime, DayOrder, ClientServiceID
								FROM 
									dbo.ClientTable z
									INNER JOIN [dbo].[ServiceStatusConnected]() s ON z.StatusId = s.ServiceStatusId
									LEFT OUTER JOIN dbo.DayTable y ON z.DayID = y.DayID
								WHERE z.ClientServiceID = a.ClientServiceID AND STATUS = 1
							) b
						WHERE b.ID = a.ID - 1 AND a.DayOrder = b.DayOrder
					), ServiceStart) < 0 
				THEN '����������� � ���������� ��������'
			ELSE NULL
		END AS GR_ERROR
	FROM
		(
			SELECT 
				ROW_NUMBER() OVER(PARTITION BY ClientServiceID ORDER BY DayOrder, ServiceStart, ServiceTime, ClientFullName) AS ID, 
				ClientID, ClientFullName, ServiceStart, ServiceTime, DayOrder, ClientServiceID
			FROM 
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				LEFT OUTER JOIN dbo.DayTable b ON a.DayID = b.DayID
			WHERE STATUS = 1
		) AS a
