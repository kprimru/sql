USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SEARCH_HISTORY_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SEARCH_HISTORY_REPORT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SEARCH_HISTORY_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	INT,
	@TYPE		NVARCHAR(MAX)
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

		DECLARE @TP	TABLE (TP INT)

		IF @TYPE IS NULL
			INSERT INTO @TP(TP)
				SELECT Id
				FROM dbo.ClientKind
		ELSE
			INSERT INTO @TP(TP)
				SELECT *
				FROM dbo.TableIDFromXML(@TYPE)

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client(CL_ID INT PRIMARY KEY)

		INSERT INTO #client(CL_ID)
			SELECT a.ClientID
			FROM
				dbo.ClientView a WITH(NOEXPAND)
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
				INNER JOIN @TP ON TP = ClientKind_Id
			WHERE	(ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)


		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				ClientID		INT	PRIMARY KEY,
				ClientFullName	VARCHAR(250),
				ManagerName		VARCHAR(100),
				ServiceName		VARCHAR(100),
				LastFile		SMALLDATETIME,
				ClientConnect	SMALLDATETIME,
				Comment			VARCHAR(500),
				DayCount		SMALLINT,
				SearchCount		SMALLINT
			)

		INSERT INTO #result(
				ClientID, ClientFullName, ManagerName, ServiceName,
				LastFile, ClientConnect, Comment, DayCount, SearchCount)
			SELECT
				ClientID, ClientFullName, ManagerName, ServiceName, LastFile, ClientConnect, Comment,
				(
					SELECT COUNT(DISTINCT SearchDay)
					FROM dbo.ClientSearchTable z
					WHERE z.ClientID = t.ClientID
						AND SearchGetDay BETWEEN @BEGIN AND @END
						AND SearchDay BETWEEN DATEADD(MONTH, -1, LastFile) AND LastFile
				) AS DayCount,
				(
					SELECT COUNT(ClientSearchID)
					FROM dbo.ClientSearchTable z
					WHERE z.ClientID = t.ClientID
						AND SearchGetDay BETWEEN @BEGIN AND @END
						AND SearchDay BETWEEN DATEADD(MONTH, -1, LastFile) AND LastFile
				) AS SearchCount
			FROM
				(
					SELECT
						b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
						(
							SELECT MAX(SearchGetDay)
							FROM dbo.ClientSearchTable z
							WHERE z.ClientID = a.CL_ID
								AND SearchGetDay BETWEEN @BEGIN AND @END
						) AS LastFile,
						(
							SELECT MIN(ConnectDate)
							FROM dbo.ClientConnectView z WITH(NOEXPAND)
							WHERE z.ClientID = a.CL_ID
						) AS ClientConnect,
						(
							SELECT TOP 1 CONVERT(VARCHAR(20), dbo.DateOf(CM_DATE), 104) + ' ' + CM_TEXT AS CM_TEXT
							FROM
								dbo.ClientSearchComments z CROSS APPLY
								(
									SELECT
										x.value('@TEXT[1]', 'VARCHAR(500)') AS CM_TEXT,
										CONVERT(DATETIME, x.value('@DATE[1]', 'VARCHAR(50)'), 121) AS CM_DATE
									FROM z.CSC_COMMENTS.nodes('/ROOT/COMMENT') t(x)
								) AS o_O
							WHERE z.CSC_ID_CLIENT = a.CL_ID AND CM_DATE >= @BEGIN AND CM_DATE < DATEADD(DAY, 1, @END)
							ORDER BY CM_DATE DESC
						) AS Comment
					FROM
						#client a
						INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.CL_ID = b.ClientID
				) AS t

		SELECT
			ClientID, ClientFullName, ManagerName, ServiceName,
			/*LastFile, */CONVERT(VARCHAR(20), LastFile, 104) AS LastFileStr,
			/*ClientConnect, */CONVERT(VARCHAR(20), ClientConnect, 104) AS ClientConnectStr,
			Comment, DayCount, SearchCount,
			(
				SELECT COUNT(ClientID)
				FROM #result b
				WHERE a.ServiceName = b.ServiceName
			) AS ClientCount,
			(
				SELECT COUNT(ClientID)
				FROM #result b
				WHERE a.ServiceName = b.ServiceName
					AND LastFile IS NULL
			) AS NoFile,
			(
				SELECT COUNT(ClientID)
				FROM #result b
				WHERE a.ServiceName = b.ServiceName
					AND DayCount >= 10
			) AS ClientGood,
			(
				SELECT COUNT(ClientID)
				FROM #result b
				WHERE a.ServiceName = b.ServiceName
					AND DayCount < 10 AND DayCount >= 4
			) AS ClientNorm,
			(
				SELECT COUNT(ClientID)
				FROM #result b
				WHERE a.ServiceName = b.ServiceName
					AND DayCount < 4
			) AS ClientBad
		FROM #result a
		ORDER BY ManagerName, ServiceName, ClientFullName

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SEARCH_HISTORY_REPORT] TO rl_search_history_report;
GO
