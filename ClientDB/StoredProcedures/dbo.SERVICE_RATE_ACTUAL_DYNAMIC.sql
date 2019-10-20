USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_RATE_ACTUAL_DYNAMIC]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,	
	@TYPE		VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SET NOCOUNT ON;
		
	DECLARE @WEEK TABLE (WEEK_ID SMALLINT PRIMARY KEY, WBEGIN SMALLDATETIME, WEND SMALLDATETIME)

	INSERT INTO @WEEK(WEEK_ID, WBEGIN, WEND)
		SELECT WEEK_ID, WBEGIN, WEND 
		FROM dbo.WeekDates(@BEGIN, @END)
	
	IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
		DROP TABLE #clientlist

	CREATE TABLE #clientlist(CL_ID INT PRIMARY KEY, SR_ID INT, ClientTypeID TinyInt)
		
	INSERT INTO #clientlist(CL_ID, SR_ID, ClientTypeID)
		SELECT ClientID, ClientServiceID, ClientTypeID
		FROM 
			dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientContractTypeID
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
			STAT_DATE
		FROM
			#clientlist a
			INNER JOIN dbo.ClientTypeTable e ON e.ClientTypeID = a.ClientTypeID
			CROSS APPLY
			(
				SELECT UIU_DATE_S, InfoBankDaily, MAX(StatisticDate) AS STAT_DATE
				FROM
					USR.USRIBDateView c WITH(NOEXPAND)
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
				CL_ID		INT,
				ServiceID	INT,
				WeekID		INT,
				WeekCount	INT
			)

	INSERT INTO #client(CL_ID, ServiceID, WeekID, WeekCount)
		SELECT 
			CL_ID, SR_ID, WEEK_ID,
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
					) AS o_O
			)
		FROM 
			#clientlist a
			CROSS JOIN @week	

	DECLARE @TOTAL	INT

	SELECT @TOTAL = COUNT(*)
	FROM #clientlist

	SELECT 
		'с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) AS WEEK_STRING,
		CONVERT(VARCHAR(20), SUM(WeekCount)) + ' из ' + CONVERT(VARCHAR(20), @TOTAL) AS ServiceCount,
		CASE @TOTAL
			WHEN 0 THEN 0
			ELSE ROUND(100 * CONVERT(DECIMAL(8, 4), SUM(WeekCount)) / @TOTAL, 2) 
		END AS ServiceRate
	FROM 
		#client z
		INNER JOIN @week c ON c.WEEK_ID = z.WeekID
	GROUP BY WBEGIN, WEND
	ORDER BY WBEGIN

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
		
	IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
		DROP TABLE #clientlist

	IF OBJECT_ID('tempdb..#updates') IS NOT NULL
		DROP TABLE #updates
END
