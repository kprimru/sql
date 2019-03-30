USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [USR].[USR_MONTH_REPORT_XL2] 
	@BEGIN1	SMALLDATETIME,
	@END1	SMALLDATETIME,
	@BEGIN2	SMALLDATETIME,
	@END2	SMALLDATETIME,
	@BEGIN3	SMALLDATETIME,
	@END3	SMALLDATETIME,
	@BEGIN4	SMALLDATETIME,
	@END4	SMALLDATETIME,
	@BEGIN5	SMALLDATETIME,
	@END5	SMALLDATETIME,
	@WEEKK	INT,
	@DATE	varchar(20) = NULL,
	@INET	BIT = NULL,
	@MANAGER	INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	IF @DATE IS NULL
		SET @DATE = CONVERT(VARCHAR(20), GETDATE(), 112)

	IF @INET IS NULL
		SET @INET = 0

	-- ������ ������� �� �����
	SET @INET = 0

	DECLARE @psystemstatus UNIQUEIDENTIFIER
	DECLARE @pclientstatus int

	SELECT @psystemstatus = DS_ID
	FROM dbo.DistrStatus
	WHERE DS_REG = 0

	SET @pclientstatus = 2

	DECLARE @MINDATE SMALLDATETIME
	DECLARE @MAXDATE SMALLDATETIME	

	DECLARE @WEEK TABLE
		(
			WEEK_ID	INT IDENTITY(1, 1) PRIMARY KEY,
			WBEGIN	SMALLDATETIME,
			WEND	SMALLDATETIME
		)

	INSERT INTO @WEEK
		SELECT @BEGIN1, @END1

	INSERT INTO @WEEK
		SELECT @BEGIN2, @END2

	INSERT INTO @WEEK
		SELECT @BEGIN3, @END3

	INSERT INTO @WEEK
		SELECT @BEGIN4, @END4

	INSERT INTO @WEEK
		SELECT @BEGIN5, @END5

	SELECT @MINDATE = MIN(WBEGIN)
	FROM @WEEK
		
	SELECT @MAXDATE = MAX(WEND)
	FROM @WEEK

	IF OBJECT_ID('tempdb..#month') IS NOT NULL
		DROP TABLE #month

	CREATE TABLE #month
		(
			UD_ID_CLIENT	INT,
			UD_ID			UNIQUEIDENTIFIER,
			UI_ID_BASE		INT,
			UI_DISTR		INT,
			UI_COMP			TINYINT,
			UIU_DATE_S		SMALLDATETIME
		)

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client (CL_ID INT PRIMARY KEY, IsOnline Bit)
	
	INSERT INTO #client(CL_ID, IsOnline)
		SELECT ClientID, CASE WHEN NOT EXISTS (SELECT *
					FROM dbo.ClientDistrView WITH(NOEXPAND)
					WHERE ID_CLIENT = ClientID
						AND DS_REG = 0
						AND DistrTypeBaseCheck = 1
						AND SystemBaseCheck = 1
						) THEN 1 ELSE 0 END
		FROM 
			dbo.ClientTable
			INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
		WHERE StatusID = @pclientstatus
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND STATUS = 1

	IF OBJECT_ID('tempdb..#system') IS NOT NULL
		DROP TABLE #system

	CREATE TABLE #system
		(
			ClientID	INT,
			SystemID	INT,
			InfoBankID	INT,
			SystemDistrNumber	INT,
			CompNumber	TINYINT
		)

	INSERT INTO #system(ClientID, SystemID, InfoBankID, SystemDistrNumber, CompNumber)
		SELECT CL_ID, b.SystemID, d.InfoBankID, DISTR, COMP
		FROM 
			#client a
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON CL_ID = ID_CLIENT
			INNER JOIN dbo.SystemBankTable c ON c.SystemID = b.SystemID
			INNER JOIN dbo.InfoBankTable d ON d.InfoBankID = c.InfoBankID
		WHERE DS_REG = 0 AND InfoBankActive = 1		

	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #system (ClientID, InfoBankID) INCLUDE (SystemID, SystemDistrNumber, CompNumber)'
	EXEC (@SQL)

	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr
	
	INSERT INTO #month(UD_ID_CLIENT, UD_ID, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE_S)
		SELECT DISTINCT UD_ID_CLIENT, UD_ID, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE_S
		FROM
			#client a 
			INNER JOIN USR.USRIBDateView b WITH(NOEXPAND) ON UD_ID_CLIENT = CL_ID
		WHERE UIU_DATE_S >= @MINDATE AND UIU_DATE_S <= @MAXDATE

	SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #month (UD_ID_CLIENT, UI_ID_BASE) INCLUDE(UIU_DATE_S, UI_DISTR, UI_COMP)'
	EXEC (@SQL)	

	IF OBJECT_ID('tempdb..#inet') IS NOT NULL
		DROP TABLE #inet

	CREATE TABLE #inet
		(
			UD_ID		UNIQUEIDENTIFIER,
			UF_PATH		TINYINT,
			UF_DATE_S	DATETIME,
			UF_KIND		VARCHAR(20)
		)

	SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #month (UD_ID_CLIENT, UI_ID_BASE) INCLUDE(UIU_DATE_S, UI_DISTR, UI_COMP)'
	EXEC (@SQL)	

	INSERT INTO #inet(UD_ID, UF_PATH, UF_DATE_S, UF_KIND)
		SELECT UD_ID, UF_PATH, UF_DATE_S, USRFileKindName
		FROM 
			#client
			INNER JOIN USR.USRFileView WITH(NOEXPAND) ON CL_ID = UD_ID_CLIENT
		WHERE UF_DATE_S >= @MINDATE AND UF_DATE_S <= @MAXDATE
		
		UNION
		
		SELECT UD_ID, 0, UIU_DATE_S, USRFileKindName
		FROM 
			#client
			INNER JOIN USR.USRDateKindView WITH(NOEXPAND) ON CL_ID = UD_ID_CLIENT
		WHERE UIU_DATE_S >= @MINDATE AND UIU_DATE_S <= @MAXDATE
			AND USRFileKindName IN ('R', 'P')
		
	SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #inet (UD_ID, UF_PATH) INCLUDE(UF_DATE_S, UF_KIND)'
	EXEC (@SQL)	

	IF OBJECT_ID('tempdb..#week_system') IS NOT NULL
		DROP TABLE #week_system

	CREATE TABLE #week_system
		(
			CL_ID	INT,
			WEEK_ID	INT,
			CNT		INT
		)

	IF @INET = 1
	BEGIN
		INSERT INTO #week_system(CL_ID, WEEK_ID, CNT)
			SELECT CL_ID, WEEK_ID, 
				(
					SELECT COUNT(*)
					FROM 
						(
							SELECT DISTINCT SystemID, UI_DISTR, UI_COMP
							FROM
								#system z INNER JOIN
								#month y ON UD_ID_CLIENT = z.CLientID 
										AND UI_ID_BASE = z.InfoBankID
										AND UI_DISTR = SystemDistrNumber
										AND UI_COMP = CompNumber
										AND CL_ID = z.ClientID
							WHERE UIU_DATE_S BETWEEN WBEGIN AND WEND
								AND EXISTS
								(
									SELECT *
									FROM #inet x
									WHERE y.UD_ID = x.UD_ID
										AND UF_DATE_S BETWEEN WBEGIN AND WEND
										AND UF_PATH IN (0, 3)
										AND UF_KIND IN ('R', 'P', 'K')
								)
							
							UNION 
		
							SELECT DISTINCT SystemID, UI_DISTR, UI_COMP
							FROM
								#system z INNER JOIN
								#month y ON UD_ID_CLIENT = z.CLientID 
										AND UI_ID_BASE = z.InfoBankID
										AND UI_DISTR = SystemDistrNumber
										AND UI_COMP = CompNumber
										AND CL_ID = z.ClientID
							WHERE UIU_DATE_S BETWEEN WBEGIN AND WEND
								AND EXISTS
									(
										SELECT *
										FROM #inet x
										WHERE y.UD_ID = x.UD_ID
											AND UF_DATE_S BETWEEN WBEGIN AND WEND
											AND UF_PATH IN (1, 2)
									)
								AND EXISTS
									(
										SELECT *
										FROM #inet x
										WHERE y.UD_ID = x.UD_ID
											AND UF_DATE_S BETWEEN WBEGIN AND WEND
											AND UF_PATH = 3
									)
						) AS o_O
				)
			FROM
				@week
				CROSS JOIN #client
	END
	ELSE
	BEGIN
		INSERT INTO #week_system(CL_ID, WEEK_ID, CNT)
			SELECT CL_ID, WEEK_ID, 
				(
					SELECT COUNT(*)
					FROM 
						(
							SELECT DISTINCT SystemID, UI_DISTR, UI_COMP
							FROM
								#system z INNER JOIN
								#month ON UD_ID_CLIENT = z.CLientID 
										AND UI_ID_BASE = z.InfoBankID
										AND UI_DISTR = SystemDistrNumber
										AND UI_COMP = CompNumber
										AND CL_ID = z.ClientID
							WHERE UIU_DATE_S BETWEEN WBEGIN AND WEND							
						) AS o_O
				)
			FROM
				@week
				CROSS JOIN #client
	END

	DECLARE @HST INT
	SELECT @HST = HostID
	FROM dbo.SystemTable
	WHERE SystemBaseName = 'LAW'

	DECLARE @WEEK_CNT INT
	SET @WEEK_CNT = 0
	
	IF @BEGIN1 IS NOT NULL
		SET @WEEK_CNT = @WEEK_CNT + 1
	IF @BEGIN2 IS NOT NULL
		SET @WEEK_CNT = @WEEK_CNT + 1
	IF @BEGIN3 IS NOT NULL
		SET @WEEK_CNT = @WEEK_CNT + 1
	IF @BEGIN4 IS NOT NULL
		SET @WEEK_CNT = @WEEK_CNT + 1
	IF @BEGIN5 IS NOT NULL
		SET @WEEK_CNT = @WEEK_CNT + 1

	SELECT
		ClientID, ServiceFullName, ManagerFullName, ClientFullName, DISTR, NET, PayTypeName, RangeValue, Category, ServicePositionName, ContractTypeName,
		CASE
			WHEN Category = 'C' AND IsOnline = 1 THEN 1.5
			ELSE 1
		END 
		*
		CASE
			WHEN ContractTypeName IN ('��������', '�������� ���', '�������� ���', '��������������� ������', '��� �������������') AND ClientBaseCount > 3 THEN 1.2
			WHEN Category = 'A' AND /*ServicePositionName <> '������-�������' AND */ContractTypeName IN ('������������', '������������ VIP', '�������� ����������', '�������� ����������') THEN 1.4
			WHEN Category = 'B' AND /*ServicePositionName <> '������-�������' AND */ContractTypeName IN ('������������', '������������ VIP', '�������� ����������', '�������� ����������') THEN 1.2
			ELSE 1
		END AS COEF,
		-- ���������� ������� (����� ���� ��������� ������ > 0
		--IsOnline, @WEEK_CNT, VISIT_CNT4, VISIT_CNT5,
		CASE
			WHEN IsOnline = 1 AND Category = 'C' THEN 2
			WHEN IsOnline = 1 AND @WEEK_CNT = 5 THEN VISIT_CNT5
			WHEN IsOnline = 1 AND @WEEK_CNT = 4 THEN VISIT_CNT4
			ELSE
				CASE
					WHEN ServicedSystemCount1 = 0 THEN 0 
					ELSE 1
				END + 
				CASE
					WHEN ServicedSystemCount2 = 0 THEN 0 
					ELSE 1
				END + 
				CASE
					WHEN ServicedSystemCount3 = 0 THEN 0 
					ELSE 1
				END + 
				CASE
					WHEN ServicedSystemCount4 = 0 THEN 0 
					ELSE 1
				END + 
				CASE
					WHEN ServicedSystemCount5 = 0 THEN 0 
					ELSE 1
				END 
		END AS VISIT_CNT,
		-- ������������ ���������� ������� (���������� ��� ��������� C)
		IsNull(CASE
			WHEN Category = 'C' THEN 2
			ELSE 5
		END, 5) AS MAX_VISIT_CNT,
		--5 AS MAX_VISIT_CNT,
		ClientBaseCount, ContractPayName, ServicedSystemCount1, ServicedSystemCount2, ServicedSystemCount3, ServicedSystemCount4, ServicedSystemCount5
	FROM
		(
			SELECT 
				b.ClientID, ServiceFullName, ManagerFullName, ClientFullName, PayTypeName, RangeValue, 
				Category, ServicePositionName, ContractTypeName, VISIT_CNT4, VISIT_CNT5, IsOnline,
				(
					SELECT TOP 1 DISTR
					FROM dbo.ClientDistrView z WITH(NOEXPAND)
					WHERE z.ID_CLIENT = b.ClientID
						AND z.DS_REG = 0
						AND z.HostID = @HST
					ORDER BY DISTR
				) AS DISTR,
				(
					SELECT TOP 1 DistrTypeName
					FROM dbo.ClientDistrView z WITH(NOEXPAND)
					WHERE z.ID_CLIENT = b.ClientID
						AND z.DS_REG = 0
						AND z.HostID = @HST
					ORDER BY DISTR
				) AS NET,
				(
					SELECT Count(*)
					FROM 
						(	
							SELECT DISTINCT SystemID, SystemDistrNumber, CompNumber
							FROM #system z
							WHERE z.ClientID = b.ClientID
						) AS o_O
				) AS ClientBaseCount,
				(
					SELECT TOP 1 ContractPayName 
					FROM 
						dbo.ContractTable LEFT OUTER JOIN                     
						dbo.ContractPayTable ON ContractTable.ContractPayID = ContractPayTable.ContractPayID
					WHERE ContractTable.ClientID = b.ClientID 
					ORDER BY ContractBegin DESC
						
				) AS ContractPayName,
				(
					SELECT CNT
					FROM #week_system z
					WHERE z.CL_ID = a.CL_ID 
						AND WEEK_ID = 1
			   ) AS ServicedSystemCount1,
			   (
					SELECT CNT
					FROM #week_system z
					WHERE z.CL_ID = a.CL_ID 
						AND WEEK_ID = 2
			   ) AS ServicedSystemCount2,
			   (
					SELECT CNT
					FROM #week_system z
					WHERE z.CL_ID = a.CL_ID 
						AND WEEK_ID = 3
			   ) AS ServicedSystemCount3,
			   (
					SELECT CNT
					FROM #week_system z
					WHERE z.CL_ID = a.CL_ID 
						AND WEEK_ID = 4               
			   ) AS ServicedSystemCount4,
			   (
					SELECT CNT
					FROM #week_system z
					WHERE z.CL_ID = a.CL_ID 
						AND WEEK_ID = 5
			   ) AS ServicedSystemCount5
			FROM 				#client a				INNER JOIN dbo.ClientTable b ON a.CL_ID = b.ClientID				INNER JOIN dbo.RangeTable c ON c.RangeID = b.RangeID 
				INNER JOIN dbo.ServiceTable d ON d.ServiceID = b.ClientServiceID 
				INNER JOIN dbo.ManagerTable e ON e.ManagerID = d.ManagerID 
				LEFT OUTER JOIN dbo.PayTypeTable f ON f.PayTypeID = b.PayTypeID
				LEFT OUTER JOIN dbo.ServicePositionTable g ON d.ServicePositionID = g.ServicePositionID
				LEFT OUTER JOIN dbo.ContractTypeTable h ON b.ClientContractTypeID = h.ContractTypeID
				LEFT OUTER JOIN dbo.ClientTypeAllView i ON i.ClientID = b.ClientID
				LEFT OUTER JOIN dbo.ClientVisitCount  j ON j.ID = b.ClientVisitCountID
		) AS o_O
	ORDER BY ManagerFullName, ServiceFullName, DISTR, ClientFullName 

	IF OBJECT_ID('tempdb..#month') IS NOT NULL
		DROP TABLE #month

	IF OBJECT_ID('tempdb..#inet') IS NOT NULL
		DROP TABLE #inet

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	IF OBJECT_ID('tempdb..#week_system') IS NOT NULL
		DROP TABLE #week_system

	IF OBJECT_ID('tempdb..#system') IS NOT NULL
		DROP TABLE #system
END
