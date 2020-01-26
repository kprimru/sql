USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_RATE_STAT_DYNAMIC]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@TYPE		VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL VARCHAR(MAX)

	DECLARE @MONTH TABLE (MID SMALLINT, MBEGIN SMALLDATETIME, MEND SMALLDATETIME)

	INSERT INTO @MONTH(MID, MBEGIN, MEND)
		SELECT MID, MBEGIN, MEND 
		FROM dbo.MonthDates(@BEGIN, @END)	

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

	IF OBJECT_ID('tempdb..#monthstat') IS NOT NULL
		DROP TABLE #monthstat

	CREATE TABLE #monthstat
		(
			CL_ID	INT,
			MID		SMALLINT,
			FL_CNT	SMALLINT
		)

	INSERT INTO #monthstat(CL_ID, MID, FL_CNT)
		SELECT 
			CL_ID, MID, 
			(
				SELECT SUM(CNT)
				FROM
					(
						SELECT 
							CASE 
								WHEN EXISTS
									(
										SELECT *
										FROM dbo.ClientStatView WITH(NOEXPAND)
										WHERE ClientID = CL_ID 
											AND DATE_S BETWEEN MBEGIN AND MEND
									) THEN 1
								ELSE 0
							END AS CNT
					) AS o_O
			)
		FROM 
			#clientlist
			CROSS JOIN @MONTH	

	SET @SQL = 'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #monthstat (CL_ID, MID)'
	EXEC (@SQL)	
	
	DECLARE @TOTAL	INT

	SELECT @TOTAL = COUNT(*)
	FROM #clientlist

	SELECT 
		'с ' + CONVERT(VARCHAR(20), MBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), MEND, 104) AS MON_STR,		
		CONVERT(VARCHAR(20), SUM(FL_CNT)) + ' из ' + CONVERT(VARCHAR(20), @TOTAL) AS ServiceCount,
		CASE @TOTAL
			WHEN 0 THEN 0
			ELSE ROUND(100 * CONVERT(DECIMAL(8, 4), SUM(FL_CNT)) / @TOTAL, 2) 
		END AS ServiceRate
	FROM 		
		#monthstat a
		INNER JOIN @MONTH b ON a.MID = b.MID
	GROUP BY MBEGIN, MEND
	ORDER BY MBEGIN

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
	
	IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
		DROP TABLE #clientlist

	IF OBJECT_ID('tempdb..#monthstat') IS NOT NULL
		DROP TABLE #monthstat
END