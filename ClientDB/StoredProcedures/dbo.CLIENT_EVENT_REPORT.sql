USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_EVENT_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_EVENT_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_EVENT_REPORT]
	@SERVICE	INT,
	@MANAGER	INT,
	@TYPE		VARCHAR(MAX),
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@STATUS		INT
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
			ClientID, ClientFullName, ServiceTypeShortName,
			ServiceName + '(' + ManagerName + ')' AS ServiceManager,
			REVERSE(STUFF(REVERSE(
				(
					SELECT SystemShortName + ', '
					FROM
						dbo.ClientDistrView d WITH(NOEXPAND)
					WHERE a.ClientID = d.ID_CLIENT
						AND DS_REG = 0
					ORDER BY SystemOrder FOR XML PATH('')
				)
			), 1, 2, '')) AS SystemList,
			REVERSE(STUFF(REVERSE(
				(
					SELECT CONVERT(VARCHAR(20), EventDate, 104) + ' ' + EventComment + CHAR(10)
					FROM dbo.EventTable g
					WHERE g.ClientID = a.ClientID
						AND g.EventActive = 1
						AND g.EventDate BETWEEN @BEGIN AND @END
					ORDER BY EventDate DESC FOR XML PATH('')
				)
			), 1, 2, '')) AS EventList
		FROM
			dbo.ClientTable a
			INNER JOIN dbo.ServiceTable b ON ServiceID = ClientServiceID
			INNER JOIN dbo.ManagerTable c ON b.ManagerID = c.ManagerID
			INNER JOIN dbo.ServiceTypeTable f ON f.ServiceTypeID = a.ServiceTypeID
			INNER JOIN dbo.GET_TABLE_FROM_LIST(@TYPE, ',') ON Item = f.ServiceTypeID
		WHERE (c.ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ClientServiceID = @SERVICE OR @SERVICE IS NULL)
			AND StatusID = @STATUS
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
GRANT EXECUTE ON [dbo].[CLIENT_EVENT_REPORT] TO rl_report_event;
GO
