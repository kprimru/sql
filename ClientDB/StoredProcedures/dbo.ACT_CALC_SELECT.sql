USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ACT_CALC_SELECT]
	@SERVICE	INT,
	@MONTH		UNIQUEIDENTIFIER,
	@TYPE		NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @PERIOD SMALLDATETIME
	
	SELECT @PERIOD = START
	FROM Common.Period
	WHERE ID = @MONTH
	
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
	
	CREATE TABLE #client
		(
			ID				UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
			ClientID		INT,
			ClientFullName	VARCHAR(500),
			ServiceName		VARCHAR(150),
			PayType			VARCHAR(150),
			ContractPay		VARCHAR(150),
			PayTypeMonth	SMALLINT
		)	
		
	INSERT INTO #client(ClientID, ClientFullName, ServiceName, PayType, ContractPay, PayTypeMonth)
		SELECT 
			ClientID, ClientFullName, ServiceName, PayTypeName, ContractPayName,
			PayTypeMonth
		FROM
			dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusID = s.ServiceStatusId
			INNER JOIN dbo.ServiceTable ON ClientServiceID = ServiceID
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
		WHERE (ServiceID = @SERVICE) 
			AND STATUS = 1 AND ID_HEAD IS NULL
			AND (@TYPE IS NULL OR b.PayTypeID IN (SELECT ID FROM dbo.TableIDFromXML(@TYPE)))
	
	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr
		
	CREATE TABLE #distr
		(
			ID			UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
			CL_ID		INT,
			DisStr		VARCHAR(50),
			SYS_REG		VARCHAR(20),
			SYS_ORD		INT,
			DISTR		INT,
			COMP		TINYINT,			
			BILL		MONEY,
			INCOME		MONEY,
			MON_DATE	SMALLDATETIME,
			PAY_DATE	SMALLDATETIME
		)

	INSERT INTO #distr(CL_ID, DisStr, SYS_REG, SYS_ORD, DISTR, COMP, MON_DATE, PAY_DATE)
		SELECT ClientID, DistrStr, SystemBaseName, SystemOrder, DISTR, COMP, PERIOD, ISNULL(DATEADD(MONTH, PayTypeMonth, PERIOD), @PERIOD)
		FROM
			(
				SELECT ClientID, DistrStr, SystemBaseName, SystemOrder, DISTR, COMP, PayTypeMonth
				FROM 
					#client
					INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON ClientID = ID_CLIENT
				WHERE (DS_REG = 0)
				
				UNION
				
				SELECT a.ClientID, DistrStr, SystemBaseName, SystemOrder, DISTR, COMP, PayTypeMonth
				FROM 
					#client a
					INNER JOIN dbo.ClientTable b ON a.ClientID = b.ID_HEAD
					INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON b.ClientID = ID_CLIENT
				WHERE (DS_REG = 0) AND b.STATUS = 1
				
				UNION
				
				SELECT ClientID, DistrStr, SystemBaseName, SystemOrder, DISTR, COMP, PayTypeMonth
				FROM 
					#client
					INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON ClientID = ID_CLIENT
					INNER JOIN 
						(
							SELECT a.SYS_REG_NAME, a.DIS_NUM, a.DIS_COMP_NUM, a.PR_DATE
							FROM 
								dbo.DBFIncomeView a
								INNER JOIN dbo.DBFBillView b ON a.SYS_REG_NAME = b.SYS_REG_NAME
															AND a.DIS_NUM = b.DIS_NUM
															AND a.DIS_COMP_NUM = b.DIS_COMP_NUM
															AND a.PR_DATE = b.PR_DATE
							WHERE a.PR_DATE <= @PERIOD
								AND a.PR_DATE >= DATEADD(YEAR, -1, @PERIOD)
								AND a.ID_PRICE = b.BD_TOTAL_PRICE
								AND a.SYS_REG_NAME <> '-'
								AND NOT EXISTS
									(
										SELECT *
										FROM dbo.DBFActView z
										WHERE a.SYS_REG_NAME = z.SYS_REG_NAME
											AND a.DIS_NUM = z.DIS_NUM
											AND a.DIS_COMP_NUM = z.DIS_COMP_NUM
											AND a.PR_DATE = z.PR_DATE
									)
						) AS o_O ON SYS_REG_NAME = SystemBaseName AND DISTR = DIS_NUM AND COMP = DIS_COMP_NUM
				WHERE (DS_REG <> 0)
				
				UNION
				
				SELECT ClientID, REPLACE(y.DistrStr, y.SystemShortName, x.SystemShortName), x.SystemBaseName, x.SystemOrder, DISTR, COMP, PayTypeMonth
				FROM 
					#client z
					INNER JOIN dbo.ClientDistrView y WITH(NOEXPAND) ON z.ClientID = y.ID_CLIENT
					INNER JOIN dbo.SystemTable x ON x.HostID = y.HostID
					INNER JOIN 
						(
							SELECT a.SYS_REG_NAME, a.DIS_NUM, a.DIS_COMP_NUM, a.PR_DATE
							FROM 
								dbo.DBFIncomeView a
								INNER JOIN dbo.DBFBillView b ON a.SYS_REG_NAME = b.SYS_REG_NAME
															AND a.DIS_NUM = b.DIS_NUM
															AND a.DIS_COMP_NUM = b.DIS_COMP_NUM
															AND a.PR_DATE = b.PR_DATE
							WHERE a.PR_DATE <= @PERIOD
								AND a.PR_DATE >= DATEADD(YEAR, -1, @PERIOD)
								AND a.ID_PRICE = b.BD_TOTAL_PRICE
								AND a.SYS_REG_NAME <> '-'
								AND NOT EXISTS
									(
										SELECT *
										FROM dbo.DBFActView z
										WHERE a.SYS_REG_NAME = z.SYS_REG_NAME
											AND a.DIS_NUM = z.DIS_NUM
											AND a.DIS_COMP_NUM = z.DIS_COMP_NUM
											AND a.PR_DATE = z.PR_DATE
									)
						) AS o_O ON SYS_REG_NAME = x.SystemBaseName AND DISTR = DIS_NUM AND COMP = DIS_COMP_NUM
				WHERE (DS_REG = 0) AND x.SystemID <> y.SystemID
				
			) AS a
			CROSS APPLY
			(
				SELECT @PERIOD AS PERIOD
					
				UNION
						
				SELECT DISTINCT PR_DATE
				FROM dbo.DBFBillView z
				WHERE z.SYS_REG_NAME = a.SystemBaseName
					AND z.DIS_NUM = a.DISTR
					AND z.DIS_COMP_NUM = a.COMP
					AND PR_DATE < @PERIOD
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.DBFActView y
							WHERE y.SYS_REG_NAME = z.SYS_REG_NAME
								AND y.DIS_NUM = z.DIS_NUM
								AND y.DIS_COMP_NUM = z.DIS_COMP_NUM
								AND y.PR_DATE = z.PR_DATE
						)
			) AS c 
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DBFActView z
				WHERE z.SYS_REG_NAME = a.SystemBaseName
					AND z.DIS_NUM = a.DISTR
					AND z.DIS_COMP_NUM = a.COMP
					AND z.PR_DATE = PERIOD
			)
				
	DELETE FROM #distr WHERE SYS_REG = 'KRF'
				
	UPDATE #distr
	SET BILL = 
		ISNULL((
			SELECT BD_TOTAL_PRICE
			FROM dbo.DBFBillView
			WHERE PR_DATE = PAY_DATE AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
		),
		(
			SELECT BD_TOTAL_PRICE
			FROM dbo.DBFBillView
			WHERE PR_DATE = MON_DATE AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
		))
		,
		INCOME = 
		(
			SELECT ID_PRICE
			FROM dbo.DBFIncomeView
			WHERE PR_DATE = PAY_DATE AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
		)
			
	SELECT DISTINCT a.ID AS TREE_ID, NULL AS TREE_PARENT, 		
		ClientID, ClientFullname + ' - ' + ISNULL(PayType, '') + ' (' + ISNULL(ContractPay, '') + ')' AS ClientFullName, NULL AS DisStr, /*BILL, INCOME, */NULL AS MON_DATE,
		NULL AS PAY_COMMENT,
		CONVERT(BIT, 
			CASE 
				WHEN EXISTS
					(
						SELECT * 
						FROM #distr b 
						WHERE a.ClientID = b.CL_ID 
							AND ISNULL(BILL, -1) <> ISNULL(INCOME, 0)
					) AND 
					EXISTS
					(
						SELECT * 
						FROM #distr b 
						WHERE a.ClientID = b.CL_ID 
							AND ISNULL(BILL, -1) = ISNULL(INCOME, 0)
					) THEN NULL
				WHEN EXISTS
					(
						SELECT * 
						FROM #distr b 
						WHERE a.ClientID = b.CL_ID 
							AND ISNULL(BILL, -1) <> ISNULL(INCOME, 0)
					) THEN 0
				ELSE 1 
			END
		) AS CHECKED,
		CONVERT(BIT, 0) AS CHECKED_DEFAULT,
		NULL AS SYS_REG, NULL AS DISTR, NULL AS COMP, NULL AS SYS_ORD,
		CONVERT(BIT, 1) AS CAN_CHECK
	FROM 
		#client a
		--INNER JOIN #distr b ON a.ClientID = b.CL_ID
	WHERE EXISTS
		(
			SELECT *
			FROM #distr b
			WHERE a.ClientID = b.CL_ID
		)
			
	UNION ALL
			
	SELECT
		b.ID AS TREE_ID, a.ID AS TREE_PARENT,
		ClientID, DisStr /*ClientFullname + ' - ' + PayType + ' (' + ContractPay + ')'*/ AS ClientFullName, DisStr, /*BILL, INCOME, */MON_DATE,
		CASE
			WHEN BILL IS NULL THEN 'ÍÅÒ Ñ×ÅÒÀ (' + CONVERT(VARCHAR(20), MON_DATE, 104) + ')'
			WHEN BILL = INCOME THEN '' 
			ELSE 'Íå îïëà÷åíî ' + CONVERT(NVARCHAR(64), ROUND(100 * (BILL - ISNULL(INCOME, 0)) / BILL, 2)) + '% ñóììû'
		END AS PAY_COMMENT,
		CONVERT(BIT, CASE WHEN BILL = INCOME THEN 1 ELSE 0 END) AS CHECKED,
		CONVERT(BIT, CASE WHEN BILL = INCOME THEN 1 ELSE 0 END) AS CHECKED_DEFAULT,
		SYS_REG, DISTR, COMP, SYS_ORD,
		CONVERT(BIT, CASE WHEN BILL IS NULL THEN 0 ELSE 1 END) AS CAN_CHECK
	FROM 
		#client a
		INNER JOIN #distr b ON a.ClientID = b.CL_ID
	ORDER BY ClientFullName, SYS_ORD, MON_DATE, DISTR
		
	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr
		
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
END
