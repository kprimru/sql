USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[SERVICE_TIME_GRAPH]
	@SERVICE	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TYPE		VARCHAR(MAX),
	@CL_CNT		INT = NULL OUTPUT,
	@CL_UN_CNT	INT = NULL OUTPUT
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

		DECLARE @SQL VARCHAR(MAX)

		DECLARE @WEEK TABLE
			(
				WEEK_ID	INT,
				WBEGIN SMALLDATETIME, 
				WEND SMALLDATETIME
			)	

		INSERT INTO @WEEK
			SELECT *
			FROM dbo.WeekDates(@BEGIN, @END)

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				CL_ID INT PRIMARY KEY
			)
		
		INSERT INTO #client(CL_ID)
			SELECT ClientID
			FROM 
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN dbo.ServiceTypeTable b ON a.ServiceTypeID = b.ServiceTypeID
			WHERE ClientServiceID = @SERVICE
				AND ServiceTypeVisit = 1
				AND STATUS = 1
			ORDER BY ClientID
			
		SELECT @CL_CNT = COUNT(*)
		FROM dbo.ClientTable a
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
		WHERE ClientServiceID = @SERVICE
			AND STATUS = 1

		SELECT @CL_UN_CNT = COUNT(*)
		FROM 
			dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			INNER JOIN dbo.ServiceTypeTable b ON a.ServiceTypeID = b.ServiceTypeID
		WHERE ClientServiceID = @SERVICE
			AND ServiceTypeVisit = 0
			AND STATUS = 1
				
		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		CREATE TABLE #res
			(
				ID	INT IDENTITY(1, 1) PRIMARY KEY,
				WEEK_ID	INT,
				DAY_NUM	SMALLDATETIME,
				START_TIME	SMALLDATETIME,
				END_TIME	SMALLDATETIME,
				REST_TIME	INT /*врем€ перерывов больше 3 часов в минутах			*/
			)

		IF OBJECT_ID('tempdb..#update') IS NOT NULL
			DROP TABLE #update	

		CREATE TABLE #update
			(	
				ID	INT IDENTITY(1, 1),
				UD_ID_CLIENT	INT,		
				UIU_MIN_DATE	SMALLDATETIME,
				UIU_MAX_DATE	SMALLDATETIME,
				UIU_DATE_S	SMALLDATETIME
			)

		INSERT INTO #update(UD_ID_CLIENT, UIU_MIN_DATE, UIU_MAX_DATE, UIU_DATE_S)
			SELECT UD_ID_CLIENT, MIN(UIU_DATE) AS MIN_DATE, MAX(UIU_DATE) AS MAX_DATE, UIU_DATE_S
			FROM 
				#client
				INNER JOIN USR.USRIBDateView WITH(NOEXPAND) ON UD_ID_CLIENT = CL_ID
			WHERE UIU_DATE_S BETWEEN @BEGIN AND @END
			GROUP BY UD_ID_CLIENT, UIU_DATE_S
			ORDER BY UIU_DATE_S, MIN(UIU_DATE), MAX(UIU_DATE)
			

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #update (UIU_DATE_S) INCLUDE(UIU_MIN_DATE, UIU_MAX_DATE)'
		EXEC (@SQL)	

		INSERT INTO #res
			(			
				WEEK_ID, DAY_NUM, START_TIME, END_TIME, REST_TIME
			)
			SELECT 
				WEEK_ID, CalendarDate, 
				(
					SELECT TOP 1 UIU_MIN_DATE
					FROM #update
					WHERE CalendarDate = UIU_DATE_S
					ORDER BY UIU_MIN_DATE
				), 
				(
					SELECT TOP 1 UIU_MAX_DATE
					FROM #update
					WHERE CalendarDate = UIU_DATE_S
					ORDER BY UIU_MIN_DATE DESC
				), 
				(
					SELECT SUM(REST)
					FROM
						(
							SELECT  
								UIU_DATE_S, 
								(
									SELECT DATEDIFF(MINUTE, a.UIU_MAX_DATE, b.UIU_MIN_DATE)
									FROM #update b
									WHERE a.ID + 1 = b.ID
										AND a.UIU_DATE_S = b.UIU_DATE_S
								) AS REST
							FROM #update a
							WHERE ID <> (SELECT MAX(ID) FROM #update)
						) AS o_O
					WHERE REST >= 180
						AND UIU_DATE_S = CalendarDate
				)
			FROM 
				@WEEK 
				INNER JOIN dbo.Calendar ON CalendarDate BETWEEN WBEGIN AND WEND


		SELECT 
			a.WEEK_ID, CalendarWork,
			DayName + ', ' + CONVERT(VARCHAR(20), DAY_NUM, 104) AS DAY_NAME,
			CASE
				WHEN START_TIME IS NULL OR END_TIME IS NULL THEN 'Ќет'
				ELSE 
					LEFT(CONVERT(VARCHAR(20), START_TIME, 108), 5) + ' - ' +
					LEFT(CONVERT(VARCHAR(20), END_TIME, 108), 5)
			END AS WORK_TIME,
			CASE DayOrder
				WHEN 1 THEN NULL
				ELSE REST_TIME
			END AS REST_TIME,
			CASE DayOrder
				WHEN 1 THEN DATEDIFF(MINUTE, START_TIME, END_TIME)
				ELSE DATEDIFF(MINUTE, START_TIME, END_TIME) - ISNULL(REST_TIME, 0)
			END AS TOTAL
		FROM 
			#res a
			INNER JOIN @WEEK b ON a.WEEK_ID = b.WEEK_ID
			INNER JOIN dbo.Calendar ON CalendarDate = DAY_NUM
			INNER JOIN dbo.DayTable ON CalendarWeekDayID = DayID
		ORDER BY DAY_NUM

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		IF OBJECT_ID('tempdb..#update') IS NOT NULL
			DROP TABLE #update	
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
