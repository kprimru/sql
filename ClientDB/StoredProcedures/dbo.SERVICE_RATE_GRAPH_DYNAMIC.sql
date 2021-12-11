USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_RATE_GRAPH_DYNAMIC]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_RATE_GRAPH_DYNAMIC]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_RATE_GRAPH_DYNAMIC]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@TYPE		VARCHAR(MAX),
	@SERVICE_TYPE	VARCHAR(MAX)
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

		DECLARE @WEEK TABLE (WEEK_ID SMALLINT, WBEGIN SMALLDATETIME, WEND SMALLDATETIME)

		INSERT INTO @WEEK(WEEK_ID, WBEGIN, WEND)
			SELECT WEEK_ID, WBEGIN, WEND
			FROM dbo.WeekDates(@BEGIN, @END)

		IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
			DROP TABLE #clientlist

		CREATE TABLE #clientlist(CL_ID INT PRIMARY KEY, SR_ID INT, SR_DAY INT)

		INSERT INTO #clientlist(CL_ID, SR_ID, SR_DAY)
			SELECT ClientID, ClientServiceID, DayOrder
			FROM
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN dbo.TableIDFromXML(@TYPE) b ON b.ID = ClientKind_Id
				INNER JOIN dbo.TableIDFromXML(@SERVICE_TYPE) c ON c.ID = ServiceTypeID
				LEFT OUTER JOIN dbo.DayTable d ON d.DayID = a.DayID
			WHERE ClientServiceID = @SERVICE AND STATUS = 1

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

		DECLARE @TOTAL INT

		SELECT @TOTAL = COUNT(*)
		FROM #clientlist

		SELECT
			'с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) AS WEEK_STR,
			CONVERT(VARCHAR(20), SUM(GRAF_CNT)) + ' из ' + CONVERT(VARCHAR(20), @TOTAL) AS ServiceCount,
			CASE @TOTAL
				WHEN 0 THEN 0
				ELSE ROUND(100 * CONVERT(DECIMAL(8, 4), SUM(GRAF_CNT)) / @TOTAL, 2)
			END AS ServiceRate
		FROM
			#weekupdate a
			INNER JOIN @week b ON a.WEEK_ID = b.WEEK_ID
		GROUP BY WBEGIN, WEND
		ORDER BY WBEGIN

		IF OBJECT_ID('tempdb..#service') IS NOT NULL
			DROP TABLE #service

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
GRANT EXECUTE ON [dbo].[SERVICE_RATE_GRAPH_DYNAMIC] TO rl_service_rate;
GO
