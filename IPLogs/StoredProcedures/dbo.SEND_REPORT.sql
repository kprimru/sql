USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SEND_REPORT]
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @currDate SMALLDATETIME
	DECLARE @currDateTmp SMALLDATETIME
	DECLARE @mondayDate SMALLDATETIME 	
	DECLARE @sundayDate SMALLDATETIME 
	
	SELECT
		@currDate = DATEADD(WEEK, -1, CONVERT(DATETIME, CONVERT(VARCHAR(20), GETDATE(), 112), 112))

	/********** ищем понедельник ************/
	SELECT @currDateTmp = @currDate	

	WHILE DATEPART(WEEKDAY, @currDateTmp) <> 1
		SELECT @currDateTmp = DATEADD(DAY, -1, @currDateTmp)	

	SELECT @mondayDate = @currDateTmp

	/********** ищем воскресенье ************/	
	SELECT @sundayDate = DATEADD(WEEK, 1, @mondayDate)
	

	IF @BEGIN IS NULL		
		SET @BEGIN = @mondayDate
	
	IF @END IS NULL
		SET @END = @sundayDate

	DECLARE @HEADER NVARCHAR(512)

	SET @HEADER = N'Отчет по пополненным клиентам ИП сервера с ' + CONVERT(VARCHAR(20), @BEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), @END, 104)

	DECLARE @SQL NVARCHAR(MAX)
	
	SET @SQL = N'

	SELECT 
		CONVERT(VARCHAR(10), '''') AS Subhost, LEFT(ClientFullName, 50) AS ClientFullName, LEFT(CA_STR, 50) AS ClientAddress, LEFT(ServiceName, 20) AS ServiceName, LEFT(ManagerName, 10) AS ManagerName,
		COUNT(CSD_START) AS UpdateCount, MAX(ISNULL(CSD_START, CSD_END)) AS UpdateLast
	FROM
		[PC275-SQL\ALPHA].ClientDB.dbo.ClientTable a INNER JOIN
		[PC275-SQL\ALPHA].ClientDB.dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID INNER JOIN
		[PC275-SQL\ALPHA].ClientDB.dbo.ManagerTable c ON c.ManagerID = b.ManagerID INNER JOIN	
		[PC275-SQL\ALPHA].ClientDB.dbo.ClientDistrView d WITH(NOEXPAND) ON d.ID_CLIENT = a.ClientID INNER JOIN
		[PC275-SQL\ALPHA].ClientDB.dbo.SystemTable e ON e.SystemID = d.SystemID INNER JOIN
		[PC275-SQL\ALPHA].ClientDB.dbo.ClientAddressView z ON z.CA_ID_CLIENT = a.ClientID INNER JOIN
		[PC275-SQL\DELTA].DBF.dbo.RegNodeTable f ON f.RN_SYS_NAME = e.SystemBaseName 
							AND f.RN_DISTR_NUM = d.DISTR
							AND f.RN_COMP_NUM = d.COMP INNER JOIN
		IPLogs.dbo.ClientStatDetail g ON CSD_SYS = e.SystemNumber 
							AND CSD_DISTR = d.DISTR
							AND CSD_COMP = d.COMP
	WHERE SystemRic = 20 AND ISNULL(g.CSD_START, g.CSD_END) >= ''' + CONVERT(VARCHAR(20), @BEGIN, 112) + ''' AND ISNULL(g.CSD_END, g.CSD_START) < ''' + CONVERT(VARCHAR(20), @END, 112) + '''
	GROUP BY ClientFullName, LEFT(CA_STR, 50), ServiceName, ManagerName

	UNION ALL

	SELECT 
		LEFT([PC275-SQL\DELTA].DBF.dbo.GET_HOST_BY_COMMENT(RN_COMMENT), 10) AS Subhost, LEFT(TO_NAME, 50), 
		LEFT((
					SELECT TOP 1 ISNULL(CT_NAME, '''') + '' '' + ST_NAME + '' '' + TA_HOME
					FROM 
						[PC275-SQL\DELTA].DBF.dbo.TOAddressTable h INNER JOIN
						[PC275-SQL\DELTA].DBF.dbo.StreetTable k ON k.ST_ID = h.TA_ID_STREET LEFT OUTER JOIN
						[PC275-SQL\DELTA].DBF.dbo.CityTable l ON l.CT_ID = k.ST_ID_CITY
					WHERE TO_ID = h.TA_ID_TO				
		), 50), LEFT(COUR_NAME, 20), NULL,
		COUNT(CSD_START) AS UpdateCount, MAX(ISNULL(CSD_START, CSD_END)) AS UpdateLast
	FROM
		[PC275-SQL\DELTA].DBF.dbo.TOTable INNER JOIN
		[PC275-SQL\DELTA].DBF.dbo.CourierTable m ON m.COUR_ID = TO_ID_COUR INNER JOIN
		[PC275-SQL\DELTA].DBF.dbo.TODistrTable n ON n.TD_ID_TO = TO_ID INNER JOIN
		[PC275-SQL\DELTA].DBF.dbo.DistrTable ON DIS_ID = TD_ID_DISTR INNER JOIN
		[PC275-SQL\DELTA].DBF.dbo.SystemTable p ON SYS_ID = DIS_ID_SYSTEM INNER JOIN
		[PC275-SQL\ALPHA].ClientDB.dbo.SystemTable q ON SystemBaseName = SYS_REG_NAME INNER JOIN
		[PC275-SQL\DELTA].DBF.dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME 
							AND RN_DISTR_NUM = DIS_NUM
							AND RN_COMP_NUM = DIS_COMP_NUM INNER JOIN
		IPLogs.dbo.ClientStatDetail z ON CSD_SYS = SystemNumber 
							AND CSD_DISTR = DIS_NUM
							AND	CSD_COMP = DIS_COMP_NUM
	WHERE SystemRic = 20 AND ISNULL(z.CSD_START, z.CSD_END) >= ''' + CONVERT(VARCHAR(20), @BEGIN, 112) + ''' AND ISNULL(z.CSD_END, z.CSD_START) < ''' + CONVERT(VARCHAR(20), @END, 112) + '''
		AND NOT EXISTS
			(
				SELECT *
				FROM
					[PC275-SQL\ALPHA].ClientDB.dbo.ClientTable a INNER JOIN
					[PC275-SQL\ALPHA].ClientDB.dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID INNER JOIN
					[PC275-SQL\ALPHA].ClientDB.dbo.ManagerTable c ON c.ManagerID = b.ManagerID INNER JOIN	
					[PC275-SQL\ALPHA].ClientDB.dbo.ClientDistrView d WITH(NOEXPAND) ON d.ID_CLIENT = a.ClientID INNER JOIN
					[PC275-SQL\ALPHA].ClientDB.dbo.SystemTable e ON e.SystemID = d.SystemID INNER JOIN
					[PC275-SQL\DELTA].DBF.dbo.RegNodeTable f ON f.RN_SYS_NAME = e.SystemBaseName 
										AND f.RN_DISTR_NUM = d.DISTR
										AND	f.RN_COMP_NUM = d.COMP INNER JOIN
					IPLogs.dbo.ClientStatDetail g ON CSD_SYS = e.SystemNumber 
										AND CSD_DISTR = d.DISTR
										AND CSD_COMP = d.COMP
				WHERE ISNULL(g.CSD_START, g.CSD_END) >= ''' + CONVERT(VARCHAR(20), @BEGIN, 112) + ''' AND ISNULL(g.CSD_END, g.CSD_START) < ''' + CONVERT(VARCHAR(20), @END, 112) + '''
					AND g.CSD_SYS = z.CSD_SYS
						AND g.CSD_DISTR = z.CSD_DISTR
						AND g.CSD_COMP = z.CSD_COMP				
			)
	GROUP BY TO_NAME, COUR_NAME, RN_COMMENT, TO_ID
	ORDER BY Subhost, ManagerName, ServiceName, ClientFullName

	'

	EXEC (@SQL)

	EXEC msdb.dbo.sp_send_dbmail @profile_name = 'SQLMail',
				@recipients = N'it@kprim.ru;ois@kprim.ru;denisov@bazis;bateneva@bazis;jurba@bazis;matv@bazis',
				@body = @HEADER,
				@query = @SQL,
				@subject='Отчет по ИП серверу',
				@query_result_header = 0,
				@attach_query_result_as_file = 1,
				@query_attachment_filename = 'ip.txt'
END
