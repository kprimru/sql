USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Training].[CLIENT_SEMINAR_VISIT_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Training].[CLIENT_SEMINAR_VISIT_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [Training].[CLIENT_SEMINAR_VISIT_REPORT]
	@BEGIN SMALLDATETIME,
	@END SMALLDATETIME,
	@SERVICE INT,
	@MANAGER INT,
	@TYPE NVARCHAR(MAX),
	@LESSON	INT,
	@CONNECT SMALLDATETIME
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		SELECT
			a.ClientID, ClientFullName, ManagerName, ServiceName, ConnectDate,
			(
				SELECT MAX(UF_DATE)
				FROM
					USR.USRActiveView z
				WHERE z.UD_ID_CLIENT = a.ClientID
			) AS LAST_UPDATE
		FROM
			dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
			INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientKind_Id
			--INNER JOIN dbo.ServiceTable b ON ClientServiceID = ServiceID
			--INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
			LEFT OUTER JOIN
				(
					SELECT ClientID, MIN(ConnectDate) AS ConnectDate
					FROM dbo.ClientConnectView WITH(NOEXPAND)
					GROUP BY ClientID
				) AS d ON d.ClientID = a.ClientID
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ConnectDate <= @CONNECT OR @CONNECT IS NULL OR ConnectDate IS NULL)
			AND NOT EXISTS
				(
					SELECT *
					FROM
						dbo.ClientStudy z
					WHERE z.ID_CLIENT = a.ClientID
						AND ID_PLACE = @LESSON
						AND DATE BETWEEN @BEGIN AND @END
						AND STATUS = 1
				)
		ORDER BY ManagerName, ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Training].[CLIENT_SEMINAR_VISIT_REPORT] TO rl_seminar_visit_report;
GO
