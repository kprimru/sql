USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_GRAPH_CORRECT]
	@serviceid INT,
	@alph BIT = NULL
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

		IF @alph = 1
			SELECT
				ROW_NUMBER() OVER(ORDER BY b.ClientFullName) AS 'RowNumber',
				b.ClientFullName, ClientTypeName, DayName, SUBSTRING(CONVERT(VARCHAR(20), ServiceStart, 108), 1, 5),
				ServiceTime, GR_ERROR
			FROM dbo.ClientTable b
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.StatusId = s.ServiceStatusId
			LEFT JOIN dbo.DayTable c ON c.DayID = b.DayID
			LEFT JOIN dbo.ClientTypeTable d ON d.ClientTypeID = b.ClientTypeID
			LEFT JOIN dbo.ClientGraphView a ON a.ClientID = b.ClientID
			WHERE b.ClientServiceID = @serviceid AND STATUS = 1
			ORDER BY b.ClientFullName
		ELSE
			SELECT
				ROW_NUMBER() OVER(ORDER BY DayOrder, ServiceStart, b.ClientFullName) AS 'RowNumber',
				b.ClientFullName, ClientTypeName, DayName, SUBSTRING(CONVERT(VARCHAR(20), ServiceStart, 108), 1, 5),
				ServiceTime, GR_ERROR
			FROM dbo.ClientTable b
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.StatusId = s.ServiceStatusId
			LEFT JOIN dbo.DayTable c ON c.DayID = b.DayID
			LEFT JOIN dbo.ClientTypeTable d ON d.ClientTypeID = b.ClientTypeID
			LEFT JOIN dbo.ClientGraphView a ON a.ClientID = b.ClientID
			WHERE b.ClientServiceID = @serviceid AND STATUS = 1
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
GRANT EXECUTE ON [dbo].[SERVICE_GRAPH_CORRECT] TO rl_report_service_graph_correct;
GO
