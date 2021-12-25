USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SEND_MONTH_REPORT]
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

	    IF @BEGIN IS NULL
		    SET @BEGIN = DATEADD(DAY, -7, CONVERT(DATETIME, CONVERT(VARCHAR(20), GETDATE(), 112), 112))

	    SET @BEGIN = DATEADD(DAY, -DATEPART(DAY, @BEGIN) + 1, @BEGIN)

	    SET @END = DATEADD(DAY, -1, DATEADD(MONTH, 1, @BEGIN))

	    DECLARE @HEADER NVARCHAR(512)

	    SET @HEADER = N'Отчет за месяц пополненным клиентам ИП сервера с ' + CONVERT(VARCHAR(20), @BEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), @END, 104)

	    DECLARE @SQL NVARCHAR(MAX)

	    SET @SQL = N'

	    SELECT
		    CONVERT(VARCHAR(1), 0) AS Subhost, LEFT(ClientFullName, 50) AS ClientFullName,
		    LEFT(CONVERT(VARCHAR(3), CSD_SYS) + ''_'' + CONVERT(VARCHAR(6), CSD_DISTR) +
			    CASE CSD_COMP
				    WHEN 1 THEN ''''
				    ELSE ''_'' + CONVERT(VARCHAR(2), CSD_COMP)
			    END, 12) AS COMPLECT,
		    LEFT(ServiceName + ''/'' + ManagerName, 35) AS ServiceName,
		    COUNT(ISNULL(CSD_START, GETDATE())) AS UpdateCount, MAX(ISNULL(ISNULL(CSD_START, CSD_END), GETDATE())) AS UpdateLast
	    FROM
		    [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable a INNER JOIN
		    [PC275-SQL\ALPHA].ClientDB.dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID INNER JOIN
		    [PC275-SQL\ALPHA].ClientDB.dbo.ManagerTable c ON c.ManagerID = b.ManagerID INNER JOIN
		    [PC275-SQL\ALPHA].ClientDB.dbo.ClientDistrView d WITH(NOEXPAND) ON d.ID_CLIENT = a.ClientID INNER JOIN
		    [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable e ON e.SystemID = d.SystemID INNER JOIN
		    [PC275-SQL\DELTA].DBF.dbo.RegNodeTable f ON f.RN_SYS_NAME = e.SystemBaseName
							    AND f.RN_DISTR_NUM = d.DISTR
							    AND f.RN_COMP_NUM = d.COMP INNER JOIN
		    IPLogs.dbo.ClientStatDetail g ON CSD_SYS = e.SystemNumber
							    AND CSD_DISTR = d.DISTR
							    AND CSD_COMP = d.COMP
	    WHERE SystemRic = 20 AND ISNULL(g.CSD_START, g.CSD_END) >= ''' + CONVERT(VARCHAR(20), @BEGIN, 112) + ''' AND ISNULL(g.CSD_END, g.CSD_START) < ''' + CONVERT(VARCHAR(20), @END, 112) + '''
	    GROUP BY ClientFullName, ServiceName, ManagerName, CSD_SYS, CSD_DISTR, CSD_COMP

	    UNION ALL

	    SELECT
		    CONVERT(VARCHAR(1), 1) AS Subhost, LEFT((Comment), 50),
		    LEFT(
			    CONVERT(VARCHAR(3), CSD_SYS) + ''_'' + CONVERT(VARCHAR(6), CSD_DISTR) +
			    CASE CSD_COMP
				    WHEN 1 THEN ''''
				    ELSE ''_'' + CONVERT(VARCHAR(2), CSD_COMP)
			    END, 12) AS COMPLECT,
		    NULL,
		    COUNT(ISNULL(CSD_START, GETDATE())) AS UpdateCount, MAX(ISNULL(ISNULL(CSD_START, CSD_END), GETDATE())) AS UpdateLast
	    FROM
		    IPLogs.dbo.ClientStatDetail z LEFT OUTER JOIN
		    [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable a ON CSD_SYS = SystemNumber  LEFT OUTER JOIN
		    [PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable b ON a.SystemBaseName = b.SystemName
							    AND CSD_DISTR = DistrNumber
							    AND	CSD_COMP = CompNumber
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
	    GROUP BY Comment, Complect, CSD_SYS, CSD_DISTR, CSD_COMP
	    ORDER BY Subhost, ServiceName, ClientFullName

	    '

	    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'SQLMail',
				    @recipients = N'it@kprim.ru;ois@kprim.ru;denisov@bazis;bateneva@bazis;jurba@bazis;matv@bazis',
				    --@recipients = N'denisov@bazis',
				    @body = @HEADER,
				    @query = @SQL,
				    @subject='Месячный отчет по ИП серверу',
				    @query_result_header = 0,
				    @attach_query_result_as_file = 1,
				    @query_attachment_filename = 'ip.txt'

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
