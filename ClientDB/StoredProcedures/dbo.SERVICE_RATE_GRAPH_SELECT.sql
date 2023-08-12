USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_RATE_GRAPH_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_RATE_GRAPH_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SERVICE_RATE_GRAPH_SELECT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	VARCHAR(MAX),
	@TYPE		VARCHAR(MAX),
	@SERVICE_TYPE	VARCHAR(MAX),
	@TOTAL		VARCHAR(30) = NULL OUTPUT,
	@TOTAL_PER	VARCHAR(20) = NULL OUTPUT
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

		IF @MANAGER IS NULL
		BEGIN
			SET @MANAGER = '<LIST>'

			SELECT @MANAGER = @MANAGER + '<ITEM>' + CONVERT(VARCHAR(20), ManagerID) + '</ITEM>'
			FROM dbo.ManagerTable

			SET @MANAGER = @MANAGER + '</LIST>'
		END

		DECLARE @SQL VARCHAR(MAX)

		DECLARE @WEEK TABLE (WEEK_ID SMALLINT, WBEGIN SMALLDATETIME, WEND SMALLDATETIME)

		INSERT INTO @WEEK(WEEK_ID, WBEGIN, WEND)
			SELECT WEEK_ID, WBEGIN, WEND
			FROM dbo.WeekDates(@BEGIN, @END)


		IF OBJECT_ID('tempdb..#service') IS NOT NULL
			DROP TABLE #service

		CREATE TABLE #service(SR_ID INT PRIMARY KEY)

		INSERT INTO #service(SR_ID)
			SELECT ServiceID
			FROM
				dbo.ServiceTable
				INNER JOIN dbo.TableIDFromXML(@MANAGER) ON ID = ManagerID
			WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
				/*AND (ManagerID = @MANAGER OR @MANAGER IS NULL)*/
				AND EXISTS
					(
						SELECT *
						FROM
							dbo.ClientTable a
							INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
							INNER JOIN dbo.TableIDFromXML(@TYPE) b ON b.ID = ClientKind_Id
							INNER JOIN dbo.TableIDFromXML(@SERVICE_TYPE) c ON c.ID = ServiceTypeID
						WHERE ClientServiceID = ServiceID
							AND STATUS = 1
					)

		IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
			DROP TABLE #clientlist

		CREATE TABLE #clientlist(CL_ID INT PRIMARY KEY, SR_ID INT, SR_DAY INT)

		INSERT INTO #clientlist(CL_ID, SR_ID, SR_DAY)
			SELECT ClientID, ClientServiceID, DayOrder
			FROM
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN #service ON ClientServiceID = SR_ID
				INNER JOIN dbo.TableIDFromXML(@TYPE) b ON b.ID = ClientKind_Id
				INNER JOIN dbo.TableIDFromXML(@SERVICE_TYPE) c ON c.ID = ServiceTypeID
				LEFT OUTER JOIN dbo.DayTable d ON d.DayID = a.DayID
			WHERE STATUS = 1

		IF OBJECT_ID('tempdb..#weekupdate') IS NOT NULL
			DROP TABLE #weekupdate

		CREATE TABLE #weekupdate
			(
				CL_ID	INT,
				WEEK_ID	SMALLINT,
				GRAF_CNT	SMALLINT
			)

		INSERT INTO #weekupdate(CL_ID, WEEK_ID, GRAF_CNT)
			SELECT
				CL_ID, WEEK_ID,
				(
					SELECT SUM(CNT)
					FROM
						(
							SELECT
								CASE
									WHEN EXISTS
										(
											SELECT *
											FROM USR.USRIBDateView WITH(NOEXPAND)
											WHERE UD_ID_CLIENT = CL_ID
												AND UIU_DATE_S BETWEEN WBEGIN AND WEND
												AND DATEPART(WEEKDAY, UIU_DATE_S) = SR_DAY
										) THEN 1
									ELSE 0
								END AS CNT
						) AS o_O
				)
			FROM
				#clientlist
				CROSS JOIN @WEEK

		SET @SQL = 'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #weekupdate (CL_ID, WEEK_ID)'
		EXEC (@SQL)

		DECLARE @WEEK_COUNT	SMALLINT

		SELECT @WEEK_COUNT = COUNT(*)
		FROM @WEEK

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
				(
					CL_ID		INT PRIMARY KEY,
					ServiceID	INT,
					UpdateCount	INT,
					WeekCount	INT
				)

		INSERT INTO #client
			(
				CL_ID, ServiceID, UpdateCount, WeekCount
			)
			SELECT
				ClientID, ClientServiceID,
				(
					SELECT COUNT(*)
					FROM #weekupdate
					WHERE ClientID = CL_ID
						AND GRAF_CNT <> 0
				),
				@WEEK_COUNT
			FROM
				#clientlist
				INNER JOIN dbo.ClientTable ON ClientID = CL_ID

		IF OBJECT_ID('tempdb..#rate') IS NOT NULL
			DROP TABLE #rate

		CREATE TABLE #rate
			(
				SR_ID			INT PRIMARY KEY,
				NormalCount		INT,
				TotalCount		INT
			)

		INSERT INTO #rate
			(
				SR_ID, NormalCount, TotalCount
			)
			SELECT
				SR_ID,
				(
					SELECT COUNT(*)
					FROM #client
					WHERE ServiceID = SR_ID
						AND UpdateCount = WeekCount
				),
				(
					SELECT COUNT(*)
					FROM #client
					WHERE ServiceID = SR_ID
				)
			FROM #service

		SELECT
			@TOTAL = CONVERT(VARCHAR(20), SUM(NormalCount)) + ' из ' + CONVERT(VARCHAR(20), SUM(TotalCount)),
			@TOTAL_PER = CONVERT(VARCHAR(20), CONVERT(DECIMAL(6, 2), ROUND(100 * CONVERT(DECIMAL(8, 4), SUM(NormalCount)) / SUM(TotalCount), 2)))
		FROM #rate

		SELECT
			ServiceID, ManagerName, ServiceName,
			CONVERT(VARCHAR(20), NormalCount) + ' из ' + CONVERT(VARCHAR(20), TotalCount) AS ServiceCount,
			ROUND(100 * CONVERT(DECIMAL(8, 4), NormalCount) / TotalCount, 2) AS ServiceRate
		FROM
			#rate
			INNER JOIN dbo.ServiceTable a ON SR_ID = ServiceID
			INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
		WHERE TotalCount <> 0
		ORDER BY ServiceName

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		IF OBJECT_ID('tempdb..#service') IS NOT NULL
			DROP TABLE #service

		IF OBJECT_ID('tempdb..#rate') IS NOT NULL
			DROP TABLE #rate

		IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
			DROP TABLE #clientlist

		IF OBJECT_ID('tempdb..#weekupdate') IS NOT NULL
			DROP TABLE #weekupdate

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_RATE_GRAPH_SELECT] TO rl_service_rate;
GO
