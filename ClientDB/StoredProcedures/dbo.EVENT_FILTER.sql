USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EVENT_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[EVENT_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[EVENT_FILTER]
	@TYPE INT,
	@SERVICE INT,
	@MANAGER INT,
	@BEGIN SMALLDATETIME,
	@END SMALLDATETIME,
	@TEXT VARCHAR(MAX) = NULL, /* текст для поиска в комментариях */
	@FLAG BIT = NULL, /* если 1 - то логическое И, если 0 - то ИЛИ */
	@CLEAR	BIT	=	 NULL
WITH EXECUTE AS OWNER
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

		IF OBJECT_ID('tempdb..#words') IS NOT NULL
			DROP TABLE #words

		CREATE TABLE #words
			(
				WRD	VARCHAR(100) PRIMARY KEY
			)

		IF @TEXT IS NOT NULL
			INSERT INTO #words(WRD)
				SELECT DISTINCT '%' + Word + '%'
				FROM dbo.SplitString(@TEXT)

		IF @TEXT IS NULL
		BEGIN
			SELECT EventID, ClientFullName, EventDate AS EventDateStr, EventTypeName, EventComment, ServiceName, ManagerName, a.ClientID, EventDate
			FROM
				[dbo].[ClientList@Get?Read]()
				INNER JOIN dbo.EventTable a ON ClientID = WCL_ID
				INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
				INNER JOIN dbo.EventTypeTable c ON a.EventTypeID = c.EventTypeID 
			WHERE EventActive = 1
				AND (a.EventTypeID = @TYPE OR @TYPE IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
				AND (EventDate <= @END OR @END IS NULL)
				AND (LTRIM(RTRIM(EventComment)) = '' OR @CLEAR <> 1)
			ORDER BY EventDate DESC, ServiceName, ClientFullName
		END
		ELSE
		BEGIN
			IF @FLAG = 1
				SELECT EventID, ClientFullName, EventDate AS EventDateStr, EventTypeName, EventComment, ServiceName, ManagerName, a.ClientID, EventDate
				FROM
					[dbo].[ClientList@Get?Read]()
					INNER JOIN dbo.EventTable a ON ClientID = WCL_ID
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN dbo.EventTypeTable c ON a.EventTypeID = c.EventTypeID 
				WHERE EventActive = 1
					AND (a.EventTypeID = @TYPE OR @TYPE IS NULL)
					AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
					AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
					AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
					AND (EventDate <= @END OR @END IS NULL)
					AND (LTRIM(RTRIM(EventComment)) = '' OR @CLEAR <> 1)
					AND NOT EXISTS
						(
							SELECT *
							FROM #words
							WHERE NOT (EventComment LIKE WRD)
						)
				ORDER BY EventDate DESC, ServiceName, ClientFullName
			ELSE
				SELECT EventID, ClientFullName, EventDate AS EventDateStr, EventTypeName, EventComment, ServiceName, ManagerName, a.ClientID, EventDate
				FROM
					[dbo].[ClientList@Get?Read]()
					INNER JOIN dbo.EventTable a ON ClientID = WCL_ID
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN dbo.EventTypeTable c ON a.EventTypeID = c.EventTypeID 
				WHERE EventActive = 1
					AND (a.EventTypeID = @TYPE OR @TYPE IS NULL)
					AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
					AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
					AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
					AND (EventDate <= @END OR @END IS NULL)
					AND (LTRIM(RTRIM(EventComment)) = '' OR @CLEAR <> 1)
					AND EXISTS
						(
							SELECT *
							FROM #words
							WHERE EventComment LIKE WRD
						)
				ORDER BY EventDate DESC, ServiceName, ClientFullName
		END

		IF OBJECT_ID('tempdb..#words') IS NOT NULL
			DROP TABLE #words

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EVENT_FILTER] TO rl_filter_event;
GO
