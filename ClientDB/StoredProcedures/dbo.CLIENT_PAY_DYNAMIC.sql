USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_PAY_DYNAMIC]
	@CLIENT	INT
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

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
			(
				ID			UNIQUEIDENTIFIER PRIMARY KEY,
				DisStr		VARCHAR(50),
				SYS_REG		VARCHAR(20),
				SYS_ORD		INT,
				DISTR		INT,
				COMP		TINYINT
			)

		INSERT INTO #distr(ID, DisStr, SYS_REG, SYS_ORD, DISTR, COMP)
			SELECT ID, DistrStr, SystemBaseName, SystemOrder, DISTR, COMP
			FROM
				dbo.ClientDistrView WITH(NOEXPAND)
			WHERE ID_CLIENT = @CLIENT AND DS_REG = 0

		IF OBJECT_ID('tempdb..#month') IS NOT NULL
			DROP TABLE #month

		CREATE TABLE #month
			(
				DATE		SMALLDATETIME PRIMARY KEY,
				MUST_PAY	SMALLDATETIME,
				COUR		VARCHAR(150)
			)

		INSERT INTO #month(DATE, MUST_PAY)
			SELECT DISTINCT
				PR_DATE,
				DATEADD(DAY,
					CASE
						WHEN DATEPART(MONTH, PR_DATE) = 2 AND DATEPART(YEAR, PR_DATE) % 4 = 0 AND ContractPayDay > 29 THEN 29
						WHEN DATEPART(MONTH, PR_DATE) = 2 AND DATEPART(YEAR, PR_DATE) % 4 <> 0 AND ContractPayDay > 28 THEN 28
						ELSE ContractPayDay - 1
					END, DATEADD(MONTH, ContractPayMonth, PR_DATE))
			FROM
				dbo.DBFIncomeView
				INNER JOIN #distr ON SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
				CROSS APPLY dbo.ClientContractPayGet(@CLIENT, PR_DATE) o_O


		UPDATE #month
		SET COUR =
			(
				SELECT TOP 1 ServiceName
				FROM
					dbo.ClientService z
					INNER JOIN dbo.ServiceTable ON ID_SERVICE = ServiceID
				WHERE ID_CLIENT = @CLIENT AND z.DATE <= #month.DATE
				ORDER BY DATE DESC
			)

		IF OBJECT_ID('tempdb..#distr_pay') IS NOT NULL
			DROP TABLE #distr_pay

		CREATE TABLE #distr_pay
			(
				ID_DISTR	UNIQUEIDENTIFIER,
				PAY_DATE	SMALLDATETIME,
				PAY_MONTH	SMALLDATETIME
			)

		INSERT INTO #distr_pay(ID_DISTR, PAY_DATE, PAY_MONTH)
			SELECT ID, IN_DATE, DATE
			FROM
				(
					SELECT ID, DATE, SYS_REG, DISTR, COMP
					FROM
						#distr
						CROSS JOIN #month
				) AS a CROSS APPLY
				(
					SELECT DISTINCT IN_DATE
					FROM dbo.DBFIncomeDateView
					WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP AND PR_DATE = DATE
				) AS b

		IF OBJECT_ID('tempdb..#pay_detail') IS NOT NULL
			DROP TABLE #pay_detail

		CREATE TABLE #pay_detail
			(
				COUR		VARCHAR(150),
				DATE		SMALLDATETIME,
				PAY_DATE	SMALLDATETIME,
				MUST_PAY	SMALLDATETIME,
				TOTAL_PAY	SMALLINT,
				PAY_IN_TIME	SMALLINT
			)

		INSERT INTO #pay_detail(COUR, DATE, PAY_DATE, MUST_PAY, TOTAL_PAY, PAY_IN_TIME)
			SELECT
				COUR, DATE, PAY_DATE, MUST_PAY, TOTAL_PAY,
				CASE
					WHEN
						(
							SELECT MAX(PAY_DATE)
							FROM
								(
									SELECT DISTINCT COUR, DATE, PAY_DATE, MUST_PAY--, DATEPART(DAY, PAY_DATE) AS PD, DATEPART(MONTH, PAY_DATE) As PM
									FROM
										#month
										LEFT OUTER JOIN #distr_pay ON PAY_MONTH = DATE
								) AS b
							WHERE a.DATE = b.DATE
						) > MUST_PAY THEN 0
					ELSE 1
				END AS PAY_IN_TIME
			FROM
				(
					SELECT
						COUR, DATE, PAY_DATE, MUST_PAY,
						CASE
							WHEN PAY_DATE =
								(
									SELECT MAX(PAY_DATE)
									FROM
										(
											SELECT DISTINCT COUR, DATE, PAY_DATE, MUST_PAY--, DATEPART(DAY, PAY_DATE) AS PD, DATEPART(MONTH, PAY_DATE) As PM
											FROM
												#month
												LEFT OUTER JOIN #distr_pay ON PAY_MONTH = DATE
										) AS b
									WHERE a.DATE = b.DATE
								) THEN 1
							ELSE 0
						END AS TOTAL_PAY
					FROM
						(
							SELECT DISTINCT COUR, DATE, PAY_DATE, MUST_PAY--, DATEPART(DAY, PAY_DATE) AS PD, DATEPART(MONTH, PAY_DATE) As PM
							FROM
								#month
								LEFT OUTER JOIN #distr_pay ON PAY_MONTH = DATE
						) AS a
				) AS a
			ORDER BY DATE DESC, PAY_DATE DESC

		--SELECT * FROM #pay_detail

		SELECT
			COUR, DATE,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 1
			) AS [1],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 2
			) AS [2],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 3
			) AS [3],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 4
			) AS [4],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 5
			) AS [5],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 6
			) AS [6],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 7
			) AS [7],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 8
			) AS [8],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 9
			) AS [9],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 10
			) AS [10],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 11
			) AS [11],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 12
			) AS [12],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 13
			) AS [13],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 14
			) AS [14],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 15
			) AS [15],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 16
			) AS [16],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 17
			) AS [17],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 18
			) AS [18],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 19
			) AS [19],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 20
			) AS [20],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 21
			) AS [21],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 22
			) AS [22],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 23
			) AS [23],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 24
			) AS [24],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 25
			) AS [25],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 26
			) AS [26],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 27
			) AS [27],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 28
			) AS [28],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 29
			) AS [29],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 30
			) AS [30],
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATEDIFF(MONTH, b.DATE, dbo.MonthOf(b.PAY_DATE))) + '|' + CONVERT(VARCHAR(20), TOTAL_PAY)  + '|' + CONVERT(VARCHAR(20), PAY_IN_TIME)
				FROM #pay_detail b
				WHERE a.DATE = b.DATE
					AND DATEPART(DAY, b.PAY_DATE) = 31
			) AS [31]
		FROM
			(
				SELECT DISTINCT COUR, DATE
				FROM #pay_detail
			) AS a
		ORDER BY DATE DESC

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		IF OBJECT_ID('tempdb..#month') IS NOT NULL
			DROP TABLE #month

		IF OBJECT_ID('tempdb..#pay_detail') IS NOT NULL
			DROP TABLE #pay_detail

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PAY_DYNAMIC] TO rl_client_pay_dynamic;
GO
