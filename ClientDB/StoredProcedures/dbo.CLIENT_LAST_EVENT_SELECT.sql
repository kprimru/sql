USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_LAST_EVENT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_LAST_EVENT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_LAST_EVENT_SELECT]
	@MON_COUNT	TINYINT,
	@MANAGER	VARCHAR(MAX)	=	NULL,
	@SERVICE	INT	=	NULL,
	@TYPE		VARCHAR(MAX) = '1,2,3,4,6',
	@MON_EQUAL	BIT =	0,
	@SERVICE_EVENT	BIT	=	0,
	@CL_TYPE	VARCHAR(MAX) = NULL,
	@CATEGORY	NVARCHAR(MAX) = NULL
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

		IF OBJECT_ID('tempdb..#event') IS NOT NULL
			DROP TABLE #event

		CREATE TABLE #event
			(
				ClientID	INT PRIMARY KEY,
				EventDate	SMALLDATETIME,
				Author		NVARCHAR(128),
				EventText	VARCHAR(MAX),
				ClientTypeID	TinyInt
			)

		IF OBJECT_ID('tempdb..#last_event') IS NOT NULL
			DROP TABLE #last_event

		CREATE TABLE #last_event
			(
				EventID		INT,
				ClientTypeID	TinyInt
			)

		IF @SERVICE_EVENT = 1
			INSERT INTO #last_event(EventID, ClientTypeID)
				SELECT
					(
						SELECT TOP 1 EventID
						FROM
							dbo.EventTable b INNER JOIN
							dbo.ServiceTable ON EventCreateUser = ServiceLogin
						WHERE a.ClientID = b.ClientID AND EventActive = 1
						ORDER BY EventDate DESC, EventID DESC
					), b.ClientTypeID
			FROM
				dbo.ClientView a WITH(NOEXPAND)
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
				INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
			WHERE	(ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID IN (SELECT ID FROM dbo.TableIDFromXml(@MANAGER)) OR @MANAGER IS NULL)
				AND (@CATEGORY IS NULL OR b.ClientTypeID IN (SELECT ID FROM dbo.TableIDFromXml(@CATEGORY)))
				AND (@TYPE IS NULL OR b.ServiceTypeID IN (SELECT ID FROM dbo.TableIDFromXml(@TYPE)))
				AND (@CL_TYPE IS NULL OR b.ClientKind_Id IN (SELECT ID FROM dbo.TableIDFromXml(@TYPE)))

		ELSE
			INSERT INTO #last_event(EventID, ClientTypeID)
				SELECT
					(
						SELECT TOP 1 EventID
						FROM
							dbo.EventTable b
						WHERE a.ClientID = b.ClientID AND EventActive = 1
						ORDER BY EventDate DESC, EventID DESC
					), a.ClientTypeID
			FROM
				dbo.ClientView a WITH(NOEXPAND)
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
				INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
			WHERE	(ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID IN (SELECT ID FROM dbo.TableIDFromXml(@MANAGER)) OR @MANAGER IS NULL)
				AND (@CATEGORY IS NULL OR b.ClientTypeID IN (SELECT ID FROM dbo.TableIDFromXml(@CATEGORY)))
				AND (@TYPE IS NULL OR b.ServiceTypeID IN (SELECT ID FROM dbo.TableIDFromXml(@TYPE)))
				AND (@CL_TYPE IS NULL OR b.ClientKind_Id IN (SELECT ID FROM dbo.TableIDFromXml(@TYPE)))


		INSERT INTO #event(ClientID, EventDate, Author, EventText, ClientTypeID)
			SELECT ClientID, EventDate, EventCreateUser, EventComment, ClientTypeID
			FROM
				#last_event a
				INNER JOIN dbo.EventTable b ON a.EventID = b.EventID


		SELECT
			a.ClientID,
			ManagerName, ServiceName, ClientFullName, CATEGORY = c.ClientTypeName,
			EventDate AS MaxDate,
			DATEDIFF(MONTH, EventDate, GETDATE()) AS DIFF_DATA,
			ISNULL(Author, '') + ' / ' + CONVERT(VARCHAR(20), EventDate, 104) + CHAR(10) + ISNULL(EventText, '') AS EventComment
		FROM
			dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN	#event t ON t.ClientID = a.ClientID
			LEFT JOIN dbo.ClientTypeTable c ON c.ClientTypeID = t.ClientTypeID
		WHERE
			(@MON_EQUAL = 0 AND DATEADD(MONTH, @MON_COUNT, EventDate) < GETDATE())
			OR (@MON_EQUAL = 1 AND dbo.MonthOf(DATEADD(MONTH, @MON_COUNT, EventDate)) = dbo.MonthOf(GETDATE()))
		ORDER BY ManagerName, ServiceName, ClientFullName

		IF OBJECT_ID('tempdb..#event') IS NOT NULL
			DROP TABLE #event

		IF OBJECT_ID('tempdb..#last_event') IS NOT NULL
			DROP TABLE #last_event

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_LAST_EVENT_SELECT] TO rl_event_audit;
GO
