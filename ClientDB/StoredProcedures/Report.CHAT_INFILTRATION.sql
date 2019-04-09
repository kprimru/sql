USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[CHAT_INFILTRATION]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ManagerName AS [������������], ServiceName AS [��], CL_CNT AS [���-�� ��������], COMPLECT_CNT AS [���������� ���������� � ����], CHAT_CNT AS [���-�� ����������, ������� ������ ����],
		ROUND(CASE
			WHEN COMPLECT_CNT = 0 THEN 0
			ELSE CONVERT(DECIMAL(8, 2), CHAT_CNT) / COMPLECT_CNT
		END * 100, 2) AS [��������� ���� (%)]
	FROM
		(
			SELECT
				ManagerName, ServiceName,
				(
					SELECT COUNT(*)
					FROM dbo.ClientTable z
					WHERE ClientServiceID = ServiceID
						AND StatusID = 2
						AND STATUS = 1
				) AS CL_CNT,
				(
					SELECT COUNT(*)
					FROM 
						dbo.HotlineDistr y
						INNER JOIN dbo.ClientDistrView x WITH(NOEXPAND) ON y.ID_HOST = x.HostID AND y.DISTR = x.DISTR AND y.COMP = x.COMP
						INNER JOIN dbo.ClientTable w ON x.ID_CLIENT = w.ClientID
						--INNER JOIN dbo.DistrTypeTable q ON q.DistrTypeID = x.DistrTypeID
						INNER JOIN Din.NetType q ON q.NT_ID_MASTER = x.DIstrTypeId
						INNER JOIN dbo.RegNodeComplectClientView z ON z.HOstiD = x.HostID AND z.DistrNumber = x.dISTR AND z.CompnUmber = x.COMP  
					WHERE ClientServiceID = a.ServiceID
						AND ClientServiceID = z.ServiceID
						AND StatusID = 2
						AND w.STATUS = 1
						AND y.STATUS = 1
						AND q.NT_TECH IN (0, 1)
						AND y.UNSET_DATE IS NULL	
						AND x.DS_REG = 0					
				) AS COMPLECT_CNT,
				(
					SELECT COUNT(*)
					FROM
						(
							SELECT DISTINCT y.HostID, z.DISTR, z.COMP
							FROM 
								dbo.HotlineChat z
								INNER JOIN dbo.SystemTable y ON z.SYS = y.SystemNumber AND SystemRic = 20
								INNER JOIN dbo.HotlineDistr t ON t.ID_HOST = y.HostID AND t.DISTR = z.DISTR AND t.COMP = z.COMP
								INNER JOIN dbo.ClientDistrView x WITH(NOEXPAND) ON y.HostID = x.HostID AND z.DISTR = x.DISTR AND z.COMP = x.COMP
								INNER JOIN dbo.ClientTable w ON x.ID_CLIENT = w.ClientID
								--INNER JOIN dbo.DistrTypeTable q ON q.DistrTypeID = x.DistrTypeID
								INNER JOIN Din.NetType q ON q.NT_ID_MASTER = x.DIstrTypeId
							WHERE ClientServiceID = ServiceID
								AND StatusID = 2
								AND w.STATUS = 1
								AND q.NT_TECH IN (0, 1)
						) AS o_O
				) AS CHAT_CNT
			FROM  
				dbo.ServiceTable a
				INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
			WHERE EXISTS
				(
					SELECT *
					FROM dbo.ClientTable z
					WHERE ClientServiceID = ServiceID
						AND StatusID = 2
						AND STATUS = 1
				)
		) AS o_O
	ORDER BY ManagerName, ServiceName
END
