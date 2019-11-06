USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[KGS_SERVICE_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@LIST	INT
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client
		(
			CL_ID	INT PRIMARY KEY,
			CL_NUM	INT
		)

	INSERT INTO #client(CL_ID, CL_NUM)
		SELECT b.ClientID, ROW_NUMBER() OVER(ORDER BY ClientFullName)
		FROM
			(	
				SELECT DISTINCT ID_CLIENT
				FROM 
					dbo.KGSDistrList
					INNER JOIN dbo.KGSDistr ON KD_ID_LIST = KDL_ID
					INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON SystemID = KD_ID_SYS
													AND DISTR = KD_DISTR
													AND COMP = KD_COMP
				WHERE KDL_ID = @LIST
			) AS o_O 
			INNER JOIN dbo.ClientTable b ON b.ClientID = o_O.ID_CLIENT
		

	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr
			
	CREATE TABLE #usr
		(
			UD_ID_CLIENT	INT,
			IB_ID			INT,
			IB_DISTR		INT,
			IB_COMP			TINYINT,
			IB_DATE			SMALLDATETIME,
			IB_DOCS			INT,
			IB_ETALON		SMALLDATETIME
		)

	INSERT INTO #usr(UD_ID_CLIENT, IB_ID, IB_DISTR, IB_COMP, IB_DATE, IB_DOCS)
		SELECT DISTINCT UD_ID_CLIENT, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE_S, UIU_DOCS
		FROM
			#client
			INNER JOIN USR.USRIBDateView WITH(NOEXPAND) ON UD_ID_CLIENT = CL_ID
		WHERE UIU_DATE_S BETWEEN @BEGIN AND @END

	DECLARE @SQL	NVARCHAR(MAX)
		
	SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #usr (UD_ID_CLIENT)'

	EXEC (@SQL)

	UPDATE #usr
	SET IB_ETALON = 
			(
				SELECT TOP 1 CalendarDate
				FROM 
					dbo.Calendar 
				WHERE CalendarDate >= 
						(
							SELECT TOP 1 StatisticDate
							FROM dbo.StatisticTable
							WHERE Docs = IB_DOCS
								AND InfoBankID = IB_ID
								AND StatisticDate <= IB_DATE
							ORDER BY StatisticDate DESC
						)
					AND CalendarWork = 1
				ORDER BY CalendarDate				
			)

	

	SELECT 
		CL_NUM,
		ClientFullName, CA_STR AS ClientAdress,
		DistrStr AS DIS_STR,
		IB_DATE, SUM(IB_DOCS) AS SYS_DOCS, MAX(IB_ETALON) AS ETALON,
		c.SystemOrder
	FROM 
		#client a
		INNER JOIN dbo.ClientTable b ON b.ClientID = a.CL_ID
		INNER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.ID_CLIENT = b.ClientID
		CROSS APPLY dbo.SystemBankGet(c.SystemID, c.DistrTypeId) d
		INNER JOIN #usr ON UD_ID_CLIENT = CL_ID
							AND InfoBankID = IB_ID
							AND DISTR = IB_DISTR
							AND COMP = IB_COMP
		INNER JOIN dbo.ClientAddressView ON CA_ID_CLIENT = a.CL_ID
	WHERE DS_REG = 0
	GROUP BY CL_NUM, ClientFullName, CA_STR, SystemFullName, DistrStr, IB_DATE, c.SystemOrder

	UNION ALL

	SELECT 
		CL_NUM,
		ClientFullName, CA_STR AS ClientAdress,
		DistrStr AS DIS_STR,
		NULL, NULL, NULL, SystemOrder
	FROM 
		#client a
		INNER JOIN dbo.ClientTable b ON b.ClientID = a.CL_ID
		INNER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.ID_CLIENT = b.ClientID
		INNER JOIN dbo.ClientAddressView ON CA_ID_CLIENT = a.CL_ID
	WHERE DS_REG = 0
		AND NOT EXISTS
		(
			SELECT *
			FROM dbo.SystemBankGet(c.SystemID, c.DistrTypeID) d 
			INNER JOIN #usr ON UD_ID_CLIENT = CL_ID
							AND InfoBankID = IB_ID
							AND DISTR = IB_DISTR
							AND COMP = IB_COMP
		)		
	ORDER BY ClientFullName, SystemOrder, IB_DATE

	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
END
