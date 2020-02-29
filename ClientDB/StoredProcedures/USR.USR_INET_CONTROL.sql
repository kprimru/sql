USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[USR_INET_CONTROL]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT
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

		SET @END = DATEADD(DAY, 1, @END)

		DECLARE @BEGIN_WEEK	SMALLDATETIME
		
		SET @BEGIN_WEEK = DATEADD(DAY, -7, @BEGIN)

		IF OBJECT_ID('tempdb..#complect') IS NOT NULL
			DROP TABLE #complect

		CREATE TABLE #complect
			(
				UD_ID			INT PRIMARY KEY,
				UD_ID_CLIENT	INT, 
				UD_NAME			NVARCHAR(64)
			)

		INSERT INTO #complect(UD_ID, UD_ID_CLIENT, UD_NAME)
		SELECT 
			UD_ID, UD_ID_CLIENT, dbo.DistrString(SystemShortName, UD_DISTR, UD_COMP)
		FROM
			USR.USRActiveView
			INNER JOIN dbo.SystemTable ON SystemID = UF_ID_SYSTEM
			INNER JOIN dbo.ClientTable ON ClientID = UD_ID_CLIENT
			INNER JOIN dbo.ServiceTable ON ClientServiceID = ServiceID
		WHERE (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND STATUS = 1
			AND NOT EXISTS
			(
				SELECT *
				FROM 
					USR.USRFile
					INNER JOIN dbo.USRFileKindTable ON USRFileKindID = UF_ID_KIND
				WHERE UF_ID_COMPLECT = UD_ID
					AND UF_PATH = 0
					AND UF_DATE >= @BEGIN 
					AND UF_DATE < @END
					AND USRFileKindName IN ('P', 'R')
			)
			AND EXISTS
			(
				SELECT *
				FROM USR.USRFile
				WHERE UF_ID_COMPLECT = UD_ID
					AND UF_PATH IN (1, 2)
					AND UF_DATE >= @BEGIN AND UF_DATE < @END
			)	

		IF OBJECT_ID('tempdb..#control') IS NOT NULL
			DROP TABLE #control

		IF OBJECT_ID('tempdb..#usr') IS NOT NULL
			DROP TABLE #usr

		CREATE TABLE #control
			(
				UD_ID		INT PRIMARY KEY,
				UF_ID		INT,
				UF_TYPE		VARCHAR(50),
				UF_DATE		SMALLDATETIME,
				UF_CREATE	DATETIME,
				UI_ID		INT,
				UI_NAME		VARCHAR(50),
				UI_DATE		SMALLDATETIME,
				UI_ACTUAL	SMALLDATETIME
			)

		INSERT INTO #control(UD_ID, UF_ID)
			SELECT 
				UD_ID,
				(
					SELECT TOP 1 UF_ID
					FROM 
						USR.USRFile 
						INNER JOIN USR.USRIB ON UI_ID_USR = UF_ID
						INNER JOIN dbo.SystemBanksView e WITH(NOEXPAND) ON UI_ID_BASE = e.InfoBankID
					WHERE UF_ID_COMPLECT = UD_ID
						AND UF_PATH = 3
						/*AND UI_LAST >= @BEGIN_WEEK AND UI_LAST < @END*/
						AND UF_DATE >= @BEGIN AND UF_DATE < @END
					ORDER BY UF_CREATE DESC, Required, SystemOrder, InfoBankOrder
				)
			FROM #complect

		UPDATE a
		SET	a.UF_TYPE = c.USRFileKindShort,
			a.UF_DATE = b.UF_DATE,
			a.UF_CREATE = b.UF_CREATE,
			a.UI_ID = 
				(
					SELECT TOP 1 UI_ID
					FROM 
						USR.USRIB d
						INNER JOIN dbo.SystemBanksView e WITH(NOEXPAND) ON d.UI_ID_BASE = e.InfoBankID					
					WHERE UI_ID_USR = a.UF_ID
					ORDER BY Required, SystemOrder, InfoBankOrder
				)
		FROM
			#control a
			INNER JOIN USR.USRFile b ON a.UF_ID = b.UF_ID
			INNER JOIN dbo.USRFileKindTable c ON c.USRFileKindID = b.UF_ID_KIND

		UPDATE a
		SET	a.UI_NAME = c.InfoBankShortName,
			a.UI_DATE	= b.UI_LAST,
			a.UI_ACTUAL	= dbo.FirstWorkDate(
				(
					SELECT TOP 1 StatisticDate
					FROM 
						dbo.StatisticTable e
					WHERE Docs = d.UIU_DOCS 
						AND e.InfoBankID = b.UI_ID_BASE
						AND e.StatisticDate <= d.UIU_DATE
					ORDER BY e.StatisticDate DESC
				))
		FROM
			#control a
			INNER JOIN USR.USRIB b ON a.UI_ID = b.UI_ID
			INNER JOIN dbo.SystemBanksView c WITH(NOEXPAND) ON UI_ID_BASE = InfoBankID
			INNER JOIN USR.USRUpdates d ON d.UIU_ID_IB = b.UI_ID
		WHERE d.UIU_INDX = 1


		CREATE TABLE #usr
			(
				UD_ID		INT PRIMARY KEY,		
				UF_ID		INT,
				UF_PATH		TINYINT,
				UF_TYPE		VARCHAR(50),
				UF_DATE		SMALLDATETIME,
				UF_CREATE	DATETIME,
				UI_ID		INT,
				UI_NAME		VARCHAR(50),
				UI_DATE		SMALLDATETIME,
				UI_ACTUAL	SMALLDATETIME
			)

		INSERT INTO #usr(UD_ID, UF_ID)
			SELECT 
				UD_ID,
				(
					SELECT TOP 1 UF_ID
					FROM USR.USRFile
					WHERE UF_ID_COMPLECT = UD_ID
						AND UF_PATH IN (1, 2)
						AND UF_DATE < @END
					ORDER BY UF_CREATE DESC
				)
			FROM #complect
		
		UPDATE a
		SET a.UF_PATH = b.UF_PATH,
			a.UF_TYPE = c.USRFileKindShort,
			a.UF_DATE = b.UF_DATE,
			a.UF_CREATE = b.UF_CREATE,
			a.UI_ID = 
				(
					SELECT TOP 1 UI_ID
					FROM 
						USR.USRIB d
						INNER JOIN dbo.SystemBanksView e WITH(NOEXPAND) ON d.UI_ID_BASE = e.InfoBankID					
					WHERE UI_ID_USR = a.UF_ID
					ORDER BY Required, SystemOrder, InfoBankOrder
				)
		FROM
			#usr a
			INNER JOIN USR.USRFile b ON a.UF_ID = b.UF_ID
			INNER JOIN dbo.USRFileKindTable c ON c.USRFileKindID = b.UF_ID_KIND
		
		UPDATE a
		SET	a.UI_NAME = c.InfoBankShortName,
			a.UI_DATE	= b.UI_LAST,
			a.UI_ACTUAL	= dbo.FirstWorkDate(
				(
					SELECT TOP 1 StatisticDate
					FROM 
						dbo.StatisticTable e
					WHERE Docs = d.UIU_DOCS 
						AND e.InfoBankID = b.UI_ID_BASE
						AND e.StatisticDate <= d.UIU_DATE
					ORDER BY e.StatisticDate DESC
				))
		FROM
			#usr a
			INNER JOIN USR.USRIB b ON a.UI_ID = b.UI_ID
			INNER JOIN dbo.InfoBankTable c ON UI_ID_BASE = InfoBankID
			INNER JOIN USR.USRUpdates d ON d.UIU_ID_IB = b.UI_ID
		WHERE d.UIU_INDX = 1

		SELECT 
			a.UD_ID,
			ManagerName, ServiceName, ClientFullName, UD_NAME, ServiceTypeShortName,
			
			CASE
				WHEN f.UF_TYPE IS NOT NULL THEN f.UF_TYPE
				WHEN f.UF_TYPE IS NULL AND z.IC_ID IS NOT NULL THEN g.UF_TYPE
				ELSE NULL
			END AS CT_TYPE, 
			CASE
				WHEN f.UF_DATE IS NOT NULL THEN CONVERT(DATETIME, CONVERT(VARCHAR(20), f.UF_DATE, 112), 112)
				WHEN f.UF_DATE IS NULL AND z.IC_ID IS NOT NULL THEN CONVERT(DATETIME, CONVERT(VARCHAR(20), g.UF_DATE, 112), 112)
				ELSE NULL
			END AS CT_DATE,
			CASE
				WHEN f.UF_CREATE IS NOT NULL THEN CONVERT(DATETIME, CONVERT(VARCHAR(20), f.UF_CREATE, 112), 112)
				WHEN f.UF_CREATE IS NULL AND z.IC_ID IS NOT NULL THEN CONVERT(DATETIME, CONVERT(VARCHAR(20), g.UF_CREATE, 112), 112)
				ELSE NULL
			END AS CT_CREATE,
			CASE
				WHEN f.UI_NAME IS NOT NULL THEN f.UI_NAME
				WHEN f.UI_NAME IS NULL AND z.IC_ID IS NOT NULL THEN g.UI_NAME
				ELSE NULL
			END AS CT_IB_NAME, 
			CASE
				WHEN f.UI_DATE IS NOT NULL THEN CONVERT(DATETIME, CONVERT(VARCHAR(20), f.UI_DATE, 112), 112)
				WHEN f.UI_DATE IS NULL AND z.IC_ID IS NOT NULL THEN CONVERT(DATETIME, CONVERT(VARCHAR(20), g.UI_DATE, 112), 112)
				ELSE NULL
			END AS CT_IB_DATE,
			CASE
				WHEN f.UI_ACTUAL IS NOT NULL THEN CONVERT(DATETIME, CONVERT(VARCHAR(20), f.UI_ACTUAL, 112), 112)
				WHEN f.UI_ACTUAl IS NULL AND z.IC_ID IS NOT NULL THEN CONVERT(DATETIME, CONVERT(VARCHAR(20), g.UI_ACTUAL, 112), 112)
				ELSE NULL
			END AS CT_IB_ACTUAL,
			dbo.CheckWorkDateTime(f.UF_DATE) AS CT_WARNING,

			g.UF_TYPE AS IN_TYPE, 
			CONVERT(DATETIME, CONVERT(VARCHAR(20), g.UF_DATE, 112), 112) AS IN_DATE, 
			CONVERT(DATETIME, CONVERT(VARCHAR(20), g.UF_CREATE, 112), 112) AS IN_CREATE, 
			g.UI_NAME AS IN_IB_NAME, 
			CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), g.UI_DATE, 112), 112) AS IN_IB_DATE, 
			CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), g.UI_ACTUAL, 112), 112) AS IN_IB_ACTUAL,
			
			CASE g.UF_PATH
				WHEN 1 THEN 'пнанр'
				WHEN 2 THEN 'хо'
				ELSE '???'
			END AS UF_PATH,
			CASE
				WHEN z.IC_ID IS NOT NULL THEN 2
				WHEN f.UF_DATE IS NULL THEN 0			
				ELSE 1
			END AS ControlStatus
		FROM 
			#complect a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON b.ClientID = a.UD_ID_CLIENT
			INNER JOIN dbo.ServiceTypeTable e ON e.ServiceTypeID = b.ServiceTypeID
			INNER JOIN #control f ON f.UD_ID = a.UD_ID
			INNER JOIN #usr g ON g.UD_ID = a.UD_ID
			LEFT OUTER JOIN USR.InetControl z ON IC_ID_COMPLECT = a.UD_ID AND IC_RDATE IS NULL	
		ORDER BY ManagerName, ServiceName, ClientFullName, UD_NAME

		IF OBJECT_ID('tempdb..#complect') IS NOT NULL
			DROP TABLE #complect

		IF OBJECT_ID('tempdb..#control') IS NOT NULL
			DROP TABLE #control

		IF OBJECT_ID('tempdb..#usr') IS NOT NULL
			DROP TABLE #usr
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
