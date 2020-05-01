USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_EVENT_FILTER]
	@TYPE		NVARCHAR(MAX),
	@CLIENT		VARCHAR(500),
	@AUTHOR		NVARCHAR(128),
	@SERVICE	INT,
	@MANAGER	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TEXT		VARCHAR(MAX) = NULL, /* текст для поиска в комментариях */
	@FLAG		BIT = NULL, /* если 1 - то логическое И, если 0 - то ИЛИ */
	@CLEAR		BIT	=	 NULL
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

		IF OBJECT_ID('tempdb..#type') IS NOT NULL
			DROP TABLE #type

		CREATE TABLE #type
			(
				TP_ID	INT PRIMARY KEY,
				TP_NAME	VARCHAR(50)
			)

		IF @TYPE IS NULL
			INSERT INTO #type(TP_ID, TP_NAME)
				SELECT EventTypeID, EventTypeName
				FROM dbo.EventTypeTable
		ELSE
			INSERT INTO #type(TP_ID, TP_NAME)
				SELECT EventTypeID, EventTypeName
				FROM
					dbo.EventTypeTable
					INNER JOIN dbo.TableIDFromXML(@TYPE) ON EventTypeID = ID

		IF @TEXT IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..#words') IS NOT NULL
				DROP TABLE #words

			CREATE TABLE #words
				(
					WRD	VARCHAR(100) PRIMARY KEY
				)

			INSERT INTO #words(WRD)
				SELECT DISTINCT '%' + Word + '%'
				FROM dbo.SplitString(@TEXT)

			IF @FLAG = 1
				SELECT
					EventID, a.CLientID, ClientFullName, EventDate, TP_NAME,
					EventComment, ServiceName, ManagerName,
					EventCreate, EventCreateUser, EventLastUpdate, EventLastUpdateUser
				FROM
					[dbo].[ClientList@Get?Read]()
					INNER JOIN dbo.EventTable a ON ClientID = WCL_ID
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN #type c ON TP_ID = EventTypeID
				WHERE EventActive = 1
					AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
					AND (a.EventTypeID = @TYPE OR @TYPE IS NULL)
					AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
					AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
					AND (EventCreateUser = @AUTHOR OR @AUTHOR IS NULL)
					AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
					AND (EventDate <= @END OR @END IS NULL)
					AND (LTRIM(RTRIM(EventComment)) = '''' OR @CLEAR <> 1)
					AND NOT EXISTS
						(
							SELECT *
							FROM #words
							WHERE NOT (EventComment LIKE WRD)
						)
				ORDER BY EventDate DESC, EventCreate DESC, ServiceName, ClientFullName
			ELSE
				SELECT
				EventID, a.CLientID, ClientFullName, EventDate, TP_NAME,
				EventComment, ServiceName, ManagerName,
				EventCreate, EventCreateUser, EventLastUpdate, EventLastUpdateUser
				FROM
					[dbo].[ClientList@Get?Read]()
					INNER JOIN dbo.EventTable a ON ClientID = WCL_ID
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN #type c ON TP_ID = EventTypeID
				WHERE EventActive = 1
					AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
					AND (a.EventTypeID = @TYPE OR @TYPE IS NULL)
					AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
					AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
					AND (EventCreateUser = @AUTHOR OR @AUTHOR IS NULL)
					AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
					AND (EventDate <= @END OR @END IS NULL)
					AND (LTRIM(RTRIM(EventComment)) = '''' OR @CLEAR <> 1)
					AND EXISTS
						(
							SELECT *
							FROM #words
							WHERE EventComment LIKE WRD
						)
				ORDER BY EventDate DESC, EventCreate DESC, ServiceName, ClientFullName

			IF OBJECT_ID('tempdb..#words') IS NOT NULL
				DROP TABLE #words
		END
		ELSE
		BEGIN
			SELECT
				EventID, a.CLientID, ClientFullName, EventDate, TP_NAME,
				EventComment, ServiceName, ManagerName,
				EventCreate, EventCreateUser, EventLastUpdate, EventLastUpdateUser
			FROM
				[dbo].[ClientList@Get?Read]()
				INNER JOIN dbo.EventTable a ON ClientID = WCL_ID
				INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
				INNER JOIN #type c ON TP_ID = EventTypeID
			WHERE EventActive = 1
				AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
				AND (a.EventTypeID = @TYPE OR @TYPE IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (EventCreateUser = @AUTHOR OR @AUTHOR IS NULL)
				AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
				AND (EventDate <= @END OR @END IS NULL)
				AND (LTRIM(RTRIM(EventComment)) = '''' OR @CLEAR <> 1)
			ORDER BY EventDate DESC, EventCreate DESC, ServiceName, ClientFullName
		END

		IF OBJECT_ID('tempdb..#type') IS NOT NULL
			DROP TABLE #type

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_EVENT_FILTER] TO rl_filter_event;
GO