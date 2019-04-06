USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CALENDAR_STATISTIC]
	@ID	INT,
	@CLIENTID INT,
	@QR INT = 3
AS
BEGIN
	SET NOCOUNT ON;	

	IF OBJECT_ID('tempdb..#report') IS NOT NULL
		DROP TABLE #report

	CREATE TABLE #report
		(
			ID	INT IDENTITY(1, 1) PRIMARY KEY,
			MASTER_ID	INT,
			VALUE_NAME	VARCHAR(50),		
			QUERY_COUNT INT,
			DAYS		INT,
			QUERY_NUM	INT,
			SMALLER		INT,
			BIGGER		INT,
			COLOR		TINYINT
		)

	/*
		Цвета: 
			1 - черный (обычный)
			2 - Зеленый
			3 - Желтый
			4 - Красный
	*/
	
	INSERT INTO #report 
			(MASTER_ID, VALUE_NAME, QUERY_COUNT, DAYS, QUERY_NUM, SMALLER, BIGGER, COLOR)
		SELECT
			NULL, CAL_NAME, NULL, 
			(
				SELECT COUNT(DISTINCT SearchDay)
				FROM 
					dbo.ClientSearchTable a 
				WHERE ClientID = @CLIENTID					
					AND SearchMonth = CAL_NAME
			),
			(
				SELECT COUNT(*)
				FROM dbo.ClientSearchTable
				WHERE ClientID = @CLIENTID
					AND SearchMonth = CAL_NAME
			),
			(
				SELECT COUNT(DISTINCT SearchDay)
				FROM dbo.ClientSearchTable z
				WHERE ClientID = @CLIENTID					
					AND SearchMonth = CAL_NAME
					AND @QR > 
						(
							SELECT COUNT(*)
							FROM dbo.ClientSearchTable y
							WHERE z.SearchDay = y.SearchDay
								AND y.ClientID = z.ClientID
						)
			),
			(
				SELECT COUNT(DISTINCT SearchDay)
				FROM dbo.ClientSearchTable z
				WHERE ClientID = @CLIENTID					
					AND SearchMonth = CAL_NAME
					AND @QR <= 
						(
							SELECT COUNT(*)
							FROM dbo.ClientSearchTable y
							WHERE z.SearchDay = y.SearchDay
								AND y.ClientID = z.ClientID
						)
			),
			NULL
		FROM
			(
				SELECT DISTINCT SearchMonth AS CAL_NAME, DATEPART(YEAR, SearchDay) CAL_YEAR, DATEPART(MONTH, SearchDay) CAL_MONTH
				FROM dbo.ClientSearchTable
				WHERE ClientID = @ClientID
			) AS o_O
		ORDER BY CAL_YEAR DESC, CAL_MONTH DESC		
	

		INSERT INTO #report 
				(MASTER_ID, VALUE_NAME, QUERY_COUNT, DAYS, QUERY_NUM, SMALLER, BIGGER, COLOR)
			SELECT 
				(
					SELECT ID
					FROM #report
					WHERE VALUE_NAME = SearchMonth
				),
				CONVERT(VARCHAR(20), SearchDay, 104), QueryCount, NULL, NULL, NULL, NULL, 4
			FROM 
				(
					SELECT SearchDay, SearchMonth, COUNT(*) AS QueryCount
					FROM dbo.ClientSearchTable
					WHERE ClientID = @CLIENTID
					GROUP BY SearchDay, SearchMonth
				) AS o_O
			ORDER BY SearchDay DESC

	SELECT *
	FROM #report
	ORDER BY ID
	

	IF OBJECT_ID('tempdb..#report') IS NOT NULL
		DROP TABLE #report

END