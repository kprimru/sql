USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_RATE_ACTUAL_SELECT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	VARCHAR(MAX),
	@TYPE		VARCHAR(MAX),
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

		DECLARE @WEEK TABLE (WEEK_ID SMALLINT PRIMARY KEY, WBEGIN SMALLDATETIME, WEND SMALLDATETIME)

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
							INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientKind_Id
						WHERE ClientServiceID = ServiceID
							AND STATUS = 1
					)


		IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
			DROP TABLE #clientlist

		CREATE TABLE #clientlist(CL_ID INT PRIMARY KEY, SR_ID INT, ClientTypeID TinyInt)

		INSERT INTO #clientlist(CL_ID, SR_ID, ClientTypeID)
			SELECT ClientID, ClientServiceID, ClientTypeID
			FROM
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN #service ON ClientServiceID = SR_ID
				INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientKind_Id
			WHERE STATUS = 1
				AND EXISTS
					(
						SELECT *
						FROM dbo.ClientDistrView z WITH(NOEXPAND)
						WHERE a.ClientID = z.ID_CLIENT AND DistrTypeBaseCheck = 1 AND DS_REG = 0
					)

		IF OBJECT_ID('tempdb..#updates') IS NOT NULL
			DROP TABLE #updates

		CREATE TABLE #updates
			(
				UD_ID_CLIENT	INT,
				UIU_DATE_S		SMALLDATETIME,
				InfoBankDaily	BIT,
				ClientTypeDailyDay	TINYINT,
				ClientTypeDay	TINYINT,
				STAT_DATE		SMALLDATETIME,
				STAT_DAILY		SMALLDATETIME,
				STAT_DAY		SMALLDATETIME
			)

		INSERT INTO #updates(UD_ID_CLIENT, UIU_DATE_S, InfoBankDaily, ClientTypeDailyDay, ClientTypeDay, STAT_DATE)
			SELECT
				UD_ID_CLIENT,
				UIU_DATE_S,
				InfoBankDaily,
				ClientTypeDailyDay, ClientTypeDay,
				STAT_DATE
			FROM
				#clientlist a
				INNER JOIN dbo.ClientTypeTable e ON a.ClientTypeID = e.ClientTypeID
				CROSS APPLY
				(
					SELECT UD_ID_CLIENT, UIU_DATE_S, InfoBankDaily, MAX(StatisticDate) AS STAT_DATE
					FROM USR.USRIBDateView c WITH(NOEXPAND)
					INNER JOIN dbo.InfoBankTable i ON i.InfoBankId = c.UI_ID_BASE AND i.InfoBankActual = 1
					INNER JOIN dbo.StatisticTable a ON Docs = UIU_DOCS
													AND a.InfoBankID = UI_ID_BASE
													AND StatisticDate <= UIU_DATE_S
					WHERE CL_ID = UD_ID_CLIENT
						AND UIU_DATE_S BETWEEN @BEGIN AND @END
					GROUP BY UIU_DATE_S, InfoBankDaily
				) AS o_O

		UPDATE #updates
		SET STAT_DAILY	=
				(
					SELECT TOP 1 CalendarDate
					FROM dbo.Calendar
					WHERE CalendarIndex =
						(
							SELECT TOP 1 CalendarIndex
							FROM
								dbo.Calendar INNER JOIN
								dbo.DayTable ON DayID = CalendarWeekDayID
							WHERE CalendarDate >= STAT_DATE
								AND DayOrder = 1
								AND CalendarWork = 1
							ORDER BY CalendarDate
						) + (ClientTypeDailyDay - 1)
						AND CalendarWork = 1
					ORDER BY CalendarDate
				),
			STAT_DAY	=
				(
					SELECT TOP 1 CalendarDate
					FROM dbo.Calendar
					WHERE CalendarIndex =
						(
							SELECT TOP 1 CalendarIndex
							FROM
								dbo.Calendar INNER JOIN
								dbo.DayTable ON DayID = CalendarWeekDayID
							WHERE CalendarDate >= STAT_DATE
								AND DayOrder = 1
								AND CalendarWork = 1
							ORDER BY CalendarDate
						) + (ClientTypeDay - 1)
						AND CalendarWork = 1
					ORDER BY CalendarDate
				)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #updates (UD_ID_CLIENT, UIU_DATE_S)'

		EXEC (@SQL)


		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
				(
					CL_ID		INT PRIMARY KEY,
					ServiceID	INT,
					ActualCount	INT,
					WeekCount	INT
				)

		INSERT INTO #client
			(
				CL_ID, ServiceID, ActualCount, WeekCount
			)
			SELECT
				CL_ID, SR_ID,
				(
					SELECT SUM(Upd)
					FROM
						(
							SELECT
								CASE
									WHEN EXISTS(
											SELECT *
											FROM #updates c
											WHERE UIU_DATE_S BETWEEN WBEGIN AND WEND
												AND UD_ID_CLIENT = CL_ID
												AND
												CASE
													WHEN STAT_DATE IS NULL THEN 'Нет'
													WHEN
														CASE InfoBankDaily
															WHEN 1 THEN STAT_DAILY
															ELSE STAT_DAY
														END < UIU_DATE_S THEN 'Нет'
													ELSE 'Да'
												END = 'Нет'
										)
										THEN 0
									ELSE 1
								END AS Upd
							FROM @WEEK b
						) AS o_O
				),
				(
					SELECT COUNT(*)
					FROM @week
				)
			FROM #clientlist a

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
						AND ActualCount = WeekCount
						AND WeekCount <> 0
				),
				(
					SELECT COUNT(*)
					FROM #client
					WHERE ServiceID = SR_ID
				)
			FROM #service

		IF (SELECT SUM(TotalCount) FROM #rate) = 0
			SELECT
				@TOTAL = CONVERT(VARCHAR(20), SUM(NormalCount)) + ' из ' + CONVERT(VARCHAR(20), SUM(TotalCount)),
				@TOTAL_PER = '0'
			FROM #rate
		ELSE
			SELECT
				@TOTAL = CONVERT(VARCHAR(20), SUM(NormalCount)) + ' из ' + CONVERT(VARCHAR(20), SUM(TotalCount)),
				@TOTAL_PER = CONVERT(VARCHAR(20), CONVERT(DECIMAL(6, 2), ROUND(100 * CONVERT(DECIMAL(8, 4), SUM(NormalCount)) / SUM(TotalCount), 2)))
			FROM #rate

		SELECT
			ServiceID, ManagerName, ServiceName,
			CONVERT(VARCHAR(20), NormalCount) + ' из ' + CONVERT(VARCHAR(20), TotalCount) AS ServiceCount,
			CASE TotalCount
				WHEN 0 THEN 0
				ELSE ROUND(100 * CONVERT(DECIMAL(8, 4), NormalCount) / TotalCount, 2)
			END AS ServiceRate
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

		IF OBJECT_ID('tempdb..#updates') IS NOT NULL
			DROP TABLE #updates

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_RATE_ACTUAL_SELECT] TO rl_service_rate;
GO
