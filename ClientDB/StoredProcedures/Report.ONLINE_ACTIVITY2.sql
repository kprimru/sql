USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ONLINE_ACTIVITY2]
	@PARAMS	NVARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = 'SELECT 
		ISNULL(ServiceName, SubhostName) AS [��/�������], ISNULL(ClientFullName, Comment) AS [������], a.DistrStr AS [�����������], 
		LGN AS [�����],
		CONVERT(SMALLDATETIME, a.RegisterDate, 104) AS [���� �����������],
		SST_SHORT AS [��� �������], NT_SHORT AS [����],'
		
	SELECT @SQL = @SQL + N'
		CASE
			(
				SELECT MAX(CONVERT(INT, ACTIVITY))
				FROM 
					dbo.OnlineActivity z
				WHERE ID_WEEK = ''' + CONVERT(NVARCHAR(64), ID) + '''
					AND z.ID_HOST = a.HostID
					AND z.DISTR = a.DistrNumber
					AND z.COMP = a.CompNumber					
			) WHEN 1 THEN ''+''
			ELSE ''''
		END AS [' + CONVERT(NVARCHAR(128), NAME) + '|����������],
		(
			SELECT SUM(LOGIN_CNT)
			FROM dbo.OnlineActivity z
			WHERE ID_WEEK = ''' + CONVERT(NVARCHAR(64), ID) + '''
				AND z.ID_HOST = a.HostID
				AND z.DISTR = a.DistrNumber
				AND z.COMP = a.CompNumber	
		) AS [' + CONVERT(NVARCHAR(128), NAME) + '|���-�� ������],
		(
			SELECT dbo.TimeMinToStr(SUM(SESSION_TIME))
			FROM dbo.OnlineActivity z
			WHERE ID_WEEK = ''' + CONVERT(NVARCHAR(64), ID) + '''
				AND z.ID_HOST = a.HostID
				AND z.DISTR = a.DistrNumber
				AND z.COMP = a.CompNumber	
		) AS [' + CONVERT(NVARCHAR(128), NAME) + '|����� ������],'
	FROM Common.Period
	WHERE TYPE = 1
		AND START >= DATEADD(MONTH, -3, GETDATE())
		AND START <= DATEADD(WEEK, -1, GETDATE())

	SET @SQL = @SQL +
	'
		(
			SELECT COUNT(*)
			FROM 
				(
					SELECT DISTINCT ID_WEEK, ID_HOST, DISTR, COMP
					FROM
						dbo.OnlineActivity z
						INNER JOIN Common.Period y ON z.ID_WEEK = y.ID				
					WHERE z.ID_HOST = a.HostID
						AND z.DISTR = a.DistrNumber
						AND z.COMP = a.CompNumber
						AND DATEADD(MONTH, 3, START) >= GETDATE()
						AND ACTIVITY = 1				
				) AS o_O
		) AS [���-�� ������ � �����������]
	FROM 	
		Reg.RegNodeSearchView a WITH(NOEXPAND)
		CROSS APPLY
			(
				SELECT DISTINCT LGN
				FROM 
					dbo.OnlineActivity q
					INNER JOIN Common.Period p ON q.ID_WEEK = p.ID
				WHERE DATEADD(MONTH, 3, START) >= GETDATE()
					AND q.ID_HOST = a.HostID
					AND q.DISTR = a.DistrNumber
					AND q.COMP = a.CompNumber
			) AS t
		LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DistrNumber = b.DISTR AND a.CompNumber = b.COMP
		LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.ClientID
	WHERE SST_SHORT NOT IN (''���'', ''���'') AND NT_SHORT IN (''���'', ''����'', ''���'', ''���1'', ''���2'', ''���-�'', ''���-� (0;1)'', ''���-� (1;0)'', ''���-� (1;2)'')
	ORDER BY CASE SubhostName WHEN '''' THEN 1 ELSE 2 END, SubhostName, ServiceName, ClientFullName, a.DistrStr'

	--PRINT (@SQL)

	EXEC (@SQL)
END
