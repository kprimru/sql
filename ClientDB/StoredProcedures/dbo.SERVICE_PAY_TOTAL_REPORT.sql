USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SERVICE_PAY_TOTAL_REPORT]
	@MANAGER		NVARCHAR(MAX),
	@MONTH			UNIQUEIDENTIFIER,
	@DAY			BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MON_DATE SMALLDATETIME

	SELECT @MON_DATE = START FROM Common.Period WHERE ID = @MONTH	
	
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
	
	CREATE TABLE #client
		(
			ServiceID		INT,
			ClientID		INT,
			ClientFullName	VARCHAR(500),
			PayType			VARCHAR(150),
			ContractPay		VARCHAR(150),
			PayDate			SMALLDATETIME,
			PayMonth		SMALLDATETIME
		)	
		
	INSERT INTO #client(ServiceID, ClientID, ClientFullName, PayType, ContractPay, PayDate, PayMonth)
		SELECT 
			ServiceID, ClientID, ClientFullName, PayTypeName, ContractPayName,
			DATEADD(MONTH, CASE WHEN ContractPayDay > DATEPART(DAY, GETDATE()) THEN -1 ELSE 0 END,
				DATEADD(DAY, 
					CASE 
						WHEN DATEPART(MONTH, @MON_DATE) = 2 AND DATEPART(YEAR, @MON_DATE) % 4 = 0 AND ContractPayDay > 29 THEN 29
						WHEN DATEPART(MONTH, @MON_DATE) = 2 AND DATEPART(YEAR, @MON_DATE) % 4 <> 0 AND ContractPayDay > 28 THEN 28
						WHEN DATEPART(MONTH, @MON_DATE) IN (4, 6, 11) AND DATEPART(YEAR, @MON_DATE) % 4 <> 0 AND ContractPayDay > 30 THEN 30
						ELSE ContractPayDay - 1
					END, DATEADD(MONTH, PayTypeMonth, @MON_DATE))),
			--DATEADD(MONTH, CASE WHEN ContractPayDay > DATEPART(DAY, GETDATE()) THEN -1 ELSE 0 END, DATEADD(MONTH, PayTypeMonth, @MON_DATE))
			CASE @DAY
				WHEN 1 THEN DATEADD(MONTH, CASE WHEN ContractPayDay > DATEPART(DAY, GETDATE()) THEN -1 ELSE 0 END, DATEADD(MONTH, PayTypeMonth, @MON_DATE))
				ELSE DATEADD(MONTH, PayTypeMonth, @MON_DATE)
			END
		FROM
			dbo.ClientTable a
			INNER JOIN dbo.ServiceTable c ON c.ServiceID = a.ClientServiceID
			INNER JOIN dbo.PayTypeTable b ON a.PayTypeID = b.PayTypeID
			OUTER APPLY
				(
					SELECT TOP 1 ContractPayName, ContractPayDay, ContractPayMonth
					FROM 
						dbo.ContractTable z
						INNER JOIN dbo.ContractPayTable y ON z.ContractPayID = y.ContractPayID
					WHERE z.ClientID = a.ClientID
					ORDER BY ContractEnd DESC
				) AS o_O
		WHERE (c.ManagerID IN (SELECT ID FROM dbo.TableIDFromXML(@MANAGER)) OR @MANAGER IS NULL) AND StatusID = 2 AND STATUS = 1 --AND ID_HEAD IS NULL
	
		
	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr
		
	CREATE TABLE #distr
		(
			CL_ID		INT,
			DisStr		VARCHAR(50),
			SYS_REG		VARCHAR(20),
			SYS_ORD		INT,
			DISTR		INT,
			COMP		TINYINT,
			BILL		MONEY,
			INCOME		MONEY,
			LAST_PAY	SMALLDATETIME,
			PAY_MON		SMALLDATETIME
		)

	INSERT INTO #distr(CL_ID, DisStr, SYS_REG, SYS_ORD, DISTR, COMP, PAY_MON/*, LAST_PAY, BILL, INCOME*/)
		SELECT ClientID, DistrStr, SystemBaseName, SystemOrder, DISTR, COMP, PayMonth	
		FROM 
			#client
			INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON ClientID = ID_CLIENT
		WHERE DS_REG = 0
		
		UNION
		
		SELECT a.ClientID, DistrStr, SystemBaseName, SystemOrder, DISTR, COMP, PayMonth
		FROM 
			#client a
			INNER JOIN dbo.ClientTable b ON a.ClientID = b.ID_HEAD
			INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON b.ClientID = ID_CLIENT
		WHERE DS_REG = 0 AND b.STATUS = 1
		
	UPDATE #distr
	SET BILL = 
		(
			SELECT BD_TOTAL_PRICE
			FROM dbo.DBFBillView WITH(NOLOCK)
			WHERE PR_DATE = PAY_MON AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
		),
		INCOME = 
		(
			SELECT ID_PRICE
			FROM dbo.DBFIncomeView WITH(NOLOCK)
			WHERE PR_DATE = PAY_MON AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
		),
		LAST_PAY = 
		(
			SELECT MAX(PR_DATE)
			FROM dbo.DBFBillRestView WITH(NOLOCK)
			WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
				AND PR_DATE <= PAY_MON AND BD_REST = 0
		)
		
	IF OBJECT_ID('tempdb..#distr_date') IS NOT NULL
		DROP TABLE #distr_date
		
	CREATE TABLE #distr_date
		(
			CL_ID	INT,
			DisStr	VARCHAR(50),
			DATE	SMALLDATETIME
		)
		
	INSERT INTO #distr_date(CL_ID, DisStr, DATE)
		SELECT CL_ID, DisStr, IN_DATE
		FROM 
			#distr
			INNER JOIN dbo.DBFIncomeDateView ON PR_DATE = PAY_MON AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
		
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result
		
	CREATE TABLE #result
		(
			ServiceID		INT,
			ClientID		INT,
			ClientFullName	VARCHAR(500),
			PayType			VARCHAR(150),
			ContractPay		VARCHAR(150),
			PayDate			SMALLDATETIME,
			PAY				VARCHAR(50),
			PRC				DECIMAL(8, 4),
			LAST_PAY		SMALLDATETIME,
			PAY_DATES		VARCHAR(MAX),
			PAY_DELTA		INT,
			LAST_MON		SMALLDATETIME
		)
		
	INSERT INTO #result(ServiceID, ClientID, ClientFullName, PayType, ContractPay, PayDate, PAY, PRC, LAST_PAY, PAY_DATES, PAY_DELTA, LAST_MON)
		SELECT 
			ServiceID, ClientID, ClientFullName, PayType, ContractPay, PayDate, 
			CASE
				WHEN BILL IS NULL THEN 'НЕТ СЧЕТА' 
				WHEN BILL = INCOME THEN 'Да' 
				ELSE 'Нет'
			END AS PAY,
			ROUND(100 * (BILL - ISNULL(INCOME, 0)) / BILL, 2) AS PRC,
			LAST_PAY, PAY_DATES,
			DATEDIFF(DAY, PayDate, LAST_PAY) AS PAY_DELTA,
			(
				SELECT MIN(LAST_PAY)
				FROM #distr
				WHERE ClientID = CL_ID
			)
		FROM 
			#client
			LEFT OUTER JOIN
				(
					SELECT 
						CL_ID, SUM(BILL) AS BILL, SUM(INCOME) AS INCOME, 
						(
							SELECT MAX(DATE)
							FROM #distr_date y
							WHERE z.CL_ID = y.CL_ID
						) AS LAST_PAY,
						REVERSE(STUFF(REVERSE((
							SELECT CONVERT(VARCHAR(20), DATE, 104) + ', '
							FROM
								(
									SELECT DISTINCT DATE
									FROM #distr_date y
									WHERE z.CL_ID = y.CL_ID
								) AS o_O
							ORDER BY DATE DESC FOR XML PATH('')
						)), 1, 2, '')) AS PAY_DATES
					FROM #distr z
					GROUP BY CL_ID
				) AS o_O ON CL_ID = ClientID
		ORDER BY ClientFullName

	--тут итоги собрать в текст			

	SELECT 
		ServiceName + ' (' + ManagerName + ')' AS ServiceStr,
		CL_COUNT, 
		PAY_BILL, PAY_INVOICE, PAY_COUNT, 
		PAY_TOTAL_BILL, PAY_TOTAL_INVOICE, PAY_TOTAL,
		CASE PAY_COUNT
			WHEN 0 THEN 0
			ELSE ROUND(100 * CONVERT(FLOAT, PAY_TOTAL) / PAY_COUNT, 0)
		END AS PAY_PERCENT
	FROM
		(
			SELECT DISTINCT
				ServiceName, ManagerName,
				(
					SELECT COUNT(*)
					FROM #client z
					WHERE a.ServiceID = z.ServiceID
				) AS CL_COUNT,
				(
					SELECT COUNT(*)
					FROM #client z
					WHERE a.ServiceID = z.ServiceID
						AND PayType IN ('по счету')
				) AS PAY_BILL,
				(
					SELECT COUNT(*)
					FROM #client z
					WHERE a.ServiceID = z.ServiceID
						AND PayType IN ('по счет-фактуре')
				) AS PAY_INVOICE,
				(
					SELECT COUNT(*)
					FROM #client z
					WHERE a.ServiceID = z.ServiceID
						AND PayType NOT IN ('не оплачивает', 'бесплатно РДД')
				) AS PAY_COUNT,
				(
					SELECT COUNT(*)
					FROM #result z
					WHERE a.ServiceID = z.ServiceID
						AND PAY = 'Да' 
						AND PayType IN ('по счету')
				) AS PAY_TOTAL_BILL,
				(
					SELECT COUNT(*)
					FROM #result z
					WHERE a.ServiceID = z.ServiceID
						AND PAY = 'Да' 
						AND PayType IN ('по счет-фактуре')
				) AS PAY_TOTAL_INVOICE,
				(
					SELECT COUNT(*)
					FROM #result z
					WHERE a.ServiceID = z.ServiceID 
						AND PAY = 'Да' 
						AND PayType NOT IN ('не оплачивает', 'бесплатно РДД')
				) AS PAY_TOTAL
			FROM
				(
					SELECT DISTINCT a.ServiceID, ServiceName, ManagerName
					FROM
						#result a
						INNER JOIN dbo.ServiceTable b ON a.ServiceID = b.ServiceID
						INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
				) AS a
		) AS o_O
	ORDER BY ManagerName, ServiceName
	
	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr
		
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
		
	IF OBJECT_ID('tempdb..#distr_date') IS NOT NULL
		DROP TABLE #distr_date
		
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result

END
