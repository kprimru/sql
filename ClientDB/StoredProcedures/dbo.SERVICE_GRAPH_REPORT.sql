USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_GRAPH_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_GRAPH_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_GRAPH_REPORT]
	@SERVICE	INT,
	@ALPH		BIT = NULL,
	@MANAGER	VARCHAR(256) = NULL OUTPUT
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

		SELECT @MANAGER = 'График СИ ' + ServiceName + ' (' + ManagerName + ')'
		FROM
			dbo.ServiceTable a
			INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
		WHERE a.ServiceID = @SERVICE

		IF @ALPH = 1
			SELECT
				ROW_NUMBER() OVER(ORDER BY b.ClientFullName) AS 'RowNumber',
				b.ClientFullName, c.CA_STR,
				ClientTypeName, DayName, SUBSTRING(CONVERT(VARCHAR(20), ServiceStart, 108), 1, 5) AS ServiceStartStr,
				ServiceTime, GR_ERROR
			FROM
				dbo.ClientTable b
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.StatusId = s.ServiceStatusId
				LEFT OUTER JOIN dbo.ClientAddressView c ON b.ClientID = c.CA_ID_CLIENT
				LEFT OUTER JOIN dbo.DayTable d ON d.DayID = b.DayID
				LEFT OUTER JOIN dbo.ClientTypeTable e ON e.ClientTypeID = b.ClientTypeID
				LEFT OUTER JOIN dbo.ClientGraphView f ON f.ClientID = b.ClientID
			WHERE b.ClientServiceID = @SERVICE
				AND STATUS = 1
			ORDER BY b.ClientFullName
		ELSE
			SELECT
				ROW_NUMBER() OVER(ORDER BY DayOrder, ServiceStart, b.ClientFullName) AS 'RowNumber',
				b.ClientFullName, c.CA_STR,
				ClientTypeName, DayName, SUBSTRING(CONVERT(VARCHAR(20), ServiceStart, 108), 1, 5) AS ServiceStartStr,
				ServiceTime, GR_ERROR
			FROM
				dbo.ClientTable b
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.StatusId = s.ServiceStatusId
				LEFT OUTER JOIN dbo.ClientAddressView c ON b.ClientID = c.CA_ID_CLIENT
				LEFT OUTER JOIN dbo.DayTable d ON d.DayID = b.DayID
				LEFT OUTER JOIN dbo.ClientTypeTable e ON e.ClientTypeID = b.ClientTypeID
				LEFT OUTER JOIN dbo.ClientGraphView f ON f.ClientID = b.ClientID
			WHERE b.ClientServiceID = @SERVICE
				AND STATUS = 1
			ORDER BY DayOrder, ServiceStart, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_GRAPH_REPORT] TO rl_report_service_graf;
GO
