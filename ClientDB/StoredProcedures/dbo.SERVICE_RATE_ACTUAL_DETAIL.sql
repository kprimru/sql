USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_RATE_ACTUAL_DETAIL]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@TYPE		VARCHAR(MAX),
	@ERROR		BIT
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

		DECLARE @WEEK TABLE (WEEK_ID SMALLINT, WBEGIN SMALLDATETIME, WEND SMALLDATETIME)

		INSERT INTO @WEEK(WEEK_ID, WBEGIN, WEND)
			SELECT WEEK_ID, WBEGIN, WEND
			FROM dbo.WeekDates(@BEGIN, @END)

		IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
			DROP TABLE #clientlist

		CREATE TABLE #clientlist(CL_ID INT PRIMARY KEY, CLientTypeID TinyInt)

		INSERT INTO #clientlist(CL_ID, ClientTypeID)
			SELECT ClientID, a.ClientTypeID
			FROM
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientKind_Id
			WHERE ClientServiceID = @SERVICE
				AND STATUS = 1
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
				MAX(StatisticDate) AS STAT_DATE
			FROM
				#clientlist b
				INNER JOIN USR.USRIBDateView c WITH(NOEXPAND) ON CL_ID = UD_ID_CLIENT
				INNER JOIN dbo.InfoBankTable i ON i.InfoBankId = c.UI_ID_BASE AND i.InfoBankActual = 1
				INNER JOIN dbo.ClientTypeTable e ON e.ClientTypeID = b.ClientTypeID
				INNER JOIN dbo.StatisticTable a ON Docs = UIU_DOCS AND a.InfoBankID = UI_ID_BASE AND StatisticDate <= UIU_DATE_S
			WHERE UIU_DATE_S BETWEEN @BEGIN AND @END
			GROUP BY UD_ID_CLIENT, UIU_DATE_S, InfoBankDaily, ClientTypeDailyDay, ClientTypeDay

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

		SELECT
			ClientID, ClientFullName, LostActual,
			CASE
				WHEN LostActual IS NULL THEN 1
				ELSE 0
			END AS ActualMatch
		FROM
			(
				SELECT
					ClientID, ClientFullName,
					REVERSE(STUFF(REVERSE(
						(
							SELECT CONVERT(VARCHAR(20), UIU_DATE_S, 104) + ', '
							FROM
								(
									SELECT DISTINCT UIU_DATE_S
									FROM #updates c
									WHERE UIU_DATE_S BETWEEN @BEGIN AND @END
										AND UD_ID_CLIENT = CL_ID
										AND
											CASE
												WHEN STAT_DATE IS NULL THEN '���'
												WHEN
													CASE InfoBankDaily
														WHEN 1 THEN STAT_DAILY
														ELSE STAT_DAY
													END < UIU_DATE_S THEN '���'
												ELSE '��'
											END = '���'
								) AS o_O
							ORDER BY UIU_DATE_S FOR XML PATH('')
						)
					), 1, 2, '')) AS LostActual
				FROM
					#clientlist a
					INNER JOIN dbo.ClientTable ON CL_ID = ClientID
			) AS o_O
		WHERE (@ERROR = 0 OR LostActual IS NOT NULL)
		ORDER BY ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_RATE_ACTUAL_DETAIL] TO rl_service_rate;
GO
