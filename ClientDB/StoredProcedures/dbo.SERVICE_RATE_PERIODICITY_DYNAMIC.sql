USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_RATE_PERIODICITY_DYNAMIC]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@TYPE		VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL VARCHAR(MAX)

	DECLARE @WEEK TABLE (WEEK_ID SMALLINT, WBEGIN SMALLDATETIME, WEND SMALLDATETIME)

	INSERT INTO @WEEK(WEEK_ID, WBEGIN, WEND)
		SELECT WEEK_ID, WBEGIN, WEND 
		FROM dbo.WeekDates(@BEGIN, @END)	

	IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
		DROP TABLE #clientlist

	CREATE TABLE #clientlist(CL_ID INT PRIMARY KEY, SR_ID INT)
		
	INSERT INTO #clientlist(CL_ID, SR_ID)
		SELECT ClientID, ClientServiceID
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

	IF OBJECT_ID('tempdb..#weekupdate') IS NOT NULL
		DROP TABLE #weekupdate

	CREATE TABLE #weekupdate
		(
			CL_ID	INT,
			WEEK_ID	SMALLINT,
			UPD_CNT	SMALLINT
		)

	INSERT INTO #weekupdate(CL_ID, WEEK_ID, UPD_CNT)
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
	
	DECLARE @TOTAL	INT

	SELECT @TOTAL = COUNT(*)
	FROM #clientlist

	SELECT 
		'с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) AS WEEK_STR,		
		CONVERT(VARCHAR(20), SUM(UPD_CNT)) + ' из ' + CONVERT(VARCHAR(20), @TOTAL) AS ServiceCount,
		CASE @TOTAL
			WHEN 0 THEN 0
			ELSE ROUND(100 * CONVERT(DECIMAL(8, 4), SUM(UPD_CNT)) / @TOTAL, 2) 
		END AS ServiceRate
	FROM 		
		#weekupdate a
		INNER JOIN @week b ON a.WEEK_ID = b.WEEK_ID
	GROUP BY WBEGIN, WEND
	ORDER BY WBEGIN

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
	
	IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
		DROP TABLE #clientlist

	IF OBJECT_ID('tempdb..#weekupdate') IS NOT NULL
		DROP TABLE #weekupdate
END