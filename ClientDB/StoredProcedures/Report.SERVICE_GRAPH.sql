USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[SERVICE_GRAPH]
	@PARAM	NVARCHAR(MAX) = NULL
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

		SELECT
			ManagerName AS [Руководитель], ServiceName AS [СИ], CL_CNT AS [Кол-во клиентов], AVG_TIME AS [Среднее время у клиента],
			dbo.TimeMinToStr(TOTAL_TIME) AS [Общее время в неделю]
		FROM
			(
				SELECT ManagerName, ServiceName, COUNT(*) AS CL_CNT, AVG(ServiceTime) AS AVG_TIME, SUM(ServiceTime) AS TOTAL_TIME
				FROM
					dbo.ClientTable a
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
					INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
					INNER JOIN dbo.ManagerTable c ON b.ManagerID = c.ManagerID
				WHERE a.STATUS = 1
				GROUP BY ManagerName, ServiceName
			) AS o_O
		ORDER BY ManagerName, ServiceName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[SERVICE_GRAPH] TO rl_report;
GO
