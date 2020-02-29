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

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

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
				SELECT Id
				FROM dbo.ClientKind
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
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
				INNER JOIN @TP ON TP = ClientKind_Id
			WHERE (ServiceID = @SERVICEID OR @SERVICEID IS NULL)
				AND	(ManagerID = @MANAGERID OR @MANAGERID IS NULL)	
		
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
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
