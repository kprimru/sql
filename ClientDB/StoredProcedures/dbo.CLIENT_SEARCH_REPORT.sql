USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SEARCH_REPORT]
	--@STATMONTH INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
    @MANAGERID	INT = NULL,
    @SERVICEID	INT = NULL,
    @TYPE		NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

	/*
	IF OBJECT_ID('tempdb..#searchcltable') IS NOT NULL
		DROP TABLE #searchcltable

	CREATE TABLE #searchcltable
		(				
			ClientID INT,
			SearchMonth nvarchar(51),
			MaxSearchDate datetime,
			NumberSearchDay int,
			NumberSearchText int,
			MaxSearchGet datetime NULL
		)

	IF OBJECT_ID('tempdb..#searchcltable3') IS NOT NULL
		DROP TABLE #searchcltable3

	CREATE TABLE #searchcltable3
		(				
            ROW INT,
			ClientID INT,
			SearchMonth nvarchar(51),
			MaxSearchDate datetime,
			NumberSearchDay int,
			NumberSearchText int,
			MaxSearchGet datetime NULL
		)
	*/
	DECLARE @TP	TABLE (TP INT)

	IF @TYPE IS NULL
		INSERT INTO @TP(TP)
			SELECT ContractTypeID
			FROM dbo.ContractTypeTable
	ELSE
		INSERT INTO @TP(TP)
			SELECT *
			FROM dbo.TableIDFromXML(@TYPE)

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client
		(
			CL_ID	INT PRIMARY KEY
		)

	INSERT INTO #client
		SELECT a.ClientID
		FROM 
			dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
			INNER JOIN @TP ON TP = ClientContractTypeID
		WHERE (ServiceID = @SERVICEID OR @SERVICEID IS NULL)
			AND	(ManagerID = @MANAGERID OR @MANAGERID IS NULL)
			AND (ServiceStatusID = 2)	

	/*
	INSERT INTO #searchcltable(ClientID, SearchMonth, MaxSearchDate, NumberSearchDay, NumberSearchText, MaxSearchGet)
		SELECT 
			CL_ID AS ClientID, SearchMonth, 
			MaxSearchDate, 
			NumberSearchDay, 
			NumberSearchText, 
			MaxSearchGet
		FROM 
			#client CT
			LEFT JOIN 
			(
				SELECT 
					ClientID, SearchMonth,
					MAX(SearchDay) AS MaxSearchDate, 
					COUNT(DISTINCT SearchDay) AS NumberSearchDay, 
					COUNT(SearchText) AS NumberSearchText, 
					MAX(SearchGet) AS MaxSearchGet
				FROM 
					#client a
					INNER JOIN [dbo].[ClientSearchTable] b ON CL_ID = CLientID
				GROUP BY ClientID, SearchMonth
			) AS C ON CL_ID = ClientID	

	INSERT INTO #searchcltable3(ROW, ClientID, SearchMonth, MaxSearchDate, NumberSearchDay, NumberSearchText, MaxSearchGet)
		SELECT 
			ROW_NUMBER() OVER(PARTITION BY H.ClientID ORDER BY H.[MaxSearchDate] DESC), 
			H.*
		FROM #searchcltable H

	SELECT 
		M.ManagerName, S.ServiceName, C.ClientFullName, /*H.ClientID,*/
		CONVERT(VARCHAR(20), CONVERT(DATETIME, CONVERT(VARCHAR(20), MAX(H.MaxSearchGet), 112), 112), 104) as MaxDateHistoryGet, 
		REVERSE(STUFF(REVERSE(
			( 
				SELECT RIGHT('0' + CONVERT(NVARCHAR(8), DATEPART(MONTH, MaxSearchDate)), 2) + '.' + DATENAME (Year,  MaxSearchDate ) +', '
				FROM #searchcltable3 
				WHERE ClientID = H.ClientID 
					AND ROW<=@STATMONTH 
					AND MaxSearchDate IS NOT NULL			
				FOR XML PATH('')
			)
		), 1, 2, '')) AS DateSearchHistory,
		SUM (H.NumberSearchDay) AS DistinctDaysSearch,
		SUM (H.NumberSearchTEXT) AS DistinctTEXTSearch,
		CASE
			WHEN SUM (H.NumberSearchDay) = 0 THEN 0
			ELSE
				CAST(
					(
						CAST(SUM(H.NumberSearchTEXT) AS DECIMAL(10,2)) / 
						CAST(SUM(H.NumberSearchDay) AS DECIMAL(10,2))
					) AS DECIMAL(7,2)
				)
		END AS KoefSearchDay,
		CONVERT(VARCHAR(20), 
		(
			SELECT MIN(ConnectDate)
			FROM dbo.ClientConnectView z WITH(NOEXPAND)
			WHERE z.ClientID = H.ClientID
		), 104)  AS ClientConnectStr
	FROM 
		#searchcltable3 H
		LEFT JOIN dbo.ClientTable C ON C.ClientID = H.ClientID
		LEFT JOIN dbo.ServiceTable S ON S.ServiceID = C.ClientServiceID
		LEFT JOIN dbo.ManagerTable M ON M.ManagerID = S.ManagerID
	WHERE H.ROW <= @STATMONTH
	GROUP BY M.ManagerName, S.ServiceName, C.ClientFullName, H.ClientID
	ORDER BY M.ManagerName, S.ServiceName, C.ClientFullName

	IF OBJECT_ID('tempdb..#searchcltable') IS NOT NULL
		DROP TABLE #searchcltable

	IF OBJECT_ID('tempdb..#searchcltable3') IS NOT NULL
		DROP TABLE #searchcltable3
	*/
	
	
	SELECT 
		ManagerName, ServiceName, ClientFullName, 		
		CONVERT(NVARCHAR(32),
			(
				SELECT MAX(SearchGetDay)
				FROM dbo.ClientSearchTable z
				WHERE z.ClientID = a.CL_ID
			)
			, 104) as MaxDateHistoryGet, 
		REVERSE(STUFF(REVERSE(
			( 
				SELECT RIGHT('0' + CONVERT(NVARCHAR(8), DATEPART(MONTH, MaxSearchDate)), 2) + '.' + DATENAME (Year,  MaxSearchDate ) +', '
				FROM 
					(
						SELECT DISTINCT SearchMonth AS MaxSearchDate
						FROM dbo.ClientSearchTable z
						WHERE z.ClientID = a.CL_ID
							AND SearchDay BETWEEN @BEGIN AND @END
					) AS o_O
				ORDER BY DATEPART(YEAR, MaxSearchDate) DESC, DATEPART(MONTH, MaxSearchDate) DESC FOR XML PATH('')
			)
		), 1, 2, '')) AS DateSearchHistory,
		
		DistinctDaysSearch,
		DistinctTEXTSearch,
		CASE
			WHEN DistinctDaysSearch = 0 THEN 0
			ELSE
				CAST(
					(
						CAST(DistinctTEXTSearch AS DECIMAL(10,2)) / 
						CAST(DistinctDaysSearch AS DECIMAL(10,2))
					) AS DECIMAL(7,2)
				)
		END AS KoefSearchDay,
		
		CONVERT(NVARCHAR(32), 
		(
			SELECT MIN(ConnectDate)
			FROM dbo.ClientConnectView z WITH(NOEXPAND)
			WHERE z.ClientID = a.CL_ID
		), 104)  AS ClientConnectStr
	FROM 
		#client a
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.CL_ID = b.ClientID
		OUTER APPLY
			(
				SELECT 
					COUNT(DISTINCT SearchDay) AS DistinctDaysSearch,
					COUNT(SearchText) AS DistinctTEXTSearch
				FROM dbo.ClientSearchTable z
				WHERE z.ClientID = a.CL_ID
					AND SearchDay BETWEEN @BEGIN AND @END 
			) AS c
	ORDER BY ManagerName, ServiceName, ClientFullName
	
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
END