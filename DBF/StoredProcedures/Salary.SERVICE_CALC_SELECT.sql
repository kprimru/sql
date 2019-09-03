USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[SERVICE_CALC_SELECT]
	@COURIER	SMALLINT,
	@PERIOD		SMALLINT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MIN_PR_DATE	SMALLDATETIME

	DECLARE @PR_BEGIN	SMALLDATETIME
	DECLARE @PR_END		SMALLDATETIME

	SELECT @PR_BEGIN = PR_DATE, @PR_END = PR_END_DATE
	FROM dbo.PeriodTable
	WHERE PR_ID = @PERIOD

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client
		(
			TO_ID		INT PRIMARY KEY,
			CL_ID		INT,
			TO_NAME		VARCHAR(250),
			CL_PSEDO	VARCHAR(50),
			CT_ID		INT,
			CT_NAME		VARCHAR(100),
			CLT_ID		SMALLINT,
			KGS			DECIMAL(8, 4),
			CL_TERR		VARCHAR(10)
		)

	INSERT INTO #client(TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, CLT_ID, CL_TERR)
		SELECT 
			TO_ID, CL_ID, TO_NAME, CL_PSEDO,
			h.CT_ID, h.CT_NAME, CL_ID_TYPE,
			CASE 
				WHEN h.CT_NAME = (SELECT CT_NAME FROM dbo.CityTable INNER JOIN dbo.CourierTable ON COUR_ID_CITY = CT_ID WHERE COUR_ID = @COURIER) THEN 'БГ'
				WHEN h.CT_NAME <> (SELECT CT_NAME FROM dbo.CityTable INNER JOIN dbo.CourierTable ON COUR_ID_CITY = CT_ID WHERE COUR_ID = @COURIER) THEN 'УТ'
				ELSE '-'
			END AS CL_TERR
		FROM 
			dbo.TOTable a
			INNER JOIN dbo.ClientTable b ON a.TO_ID_CLIENT = b.CL_ID
			INNER JOIN dbo.TOAddressTable e ON e.TA_ID_TO = a.TO_ID
			INNER JOIN dbo.StreetTable f ON f.ST_ID = e.TA_ID_STREET
			INNER JOIN dbo.CityTable g ON g.CT_ID = f.ST_ID_CITY
			LEFT OUTER JOIN dbo.CityTable h ON h.CT_ID = g.CT_ID_BASE			
		WHERE TO_ID_COUR = @COURIER

	UPDATE a
	SET KGS = 
		CAST((
			SELECT COUNT(*)
			FROM 
				#client b
				INNER JOIN dbo.ClientTypeTable c ON b.CLT_ID = c.CLT_ID
			WHERE b.CT_ID = a.CT_ID
				AND CLT_NAME LIKE '%КГС%'
		) AS DECIMAL(8, 4)) / 
		NULLIF((
			SELECT COUNT(*)
			FROM 
				#client b
			WHERE b.CT_ID = a.CT_ID
				--AND CLT_NAME LIKE '%КГС%'
		), 0)
	FROM #client a

	UPDATE #client
	SET KGS = ROUND(KGS * 100, 2)
	
	/*
	либо все периоды акта за этот месяц
	либо текущий счет
	что есть - ту сумму и периоды лепить
	*/		

	SELECT
		TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, CLT_ID, CLT_NAME, KGS, PR_ID, PR_DATE,	CL_TERR,	
		
		CLIENT_TOTAL_PRICE, TO_COUNT, TO_PRICE, CPS_PERCENT, TO_CALC,
		
		CPS_MIN, CPS_MAX, CPS_INET, CPS_PAY, CPS_ACT,
				
		CPS_COEF, SYS_COUNT, KOB,
		
		PAY, CALC,				
		
		NOTE, UPDATES, ACT, INET,
		
		TO_RESULT, ROUND(TO_RESULT * 0.87, 0) AS TO_HANDS,
		
		TO_RESULT * ISNULL(PAY, 1) AS TO_PAY_RESULT, ROUND(TO_RESULT * 0.87, 0) * ISNULL(PAY, 1) AS TO_PAY_HANDS
	FROM
		(
			SELECT
				TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, CLT_ID, CLT_NAME, KGS, PR_ID, PR_DATE,	CL_TERR,	
				
				CLIENT_TOTAL_PRICE, TO_COUNT, TO_PRICE, CPS_PERCENT, TO_CALC,
				
				CPS_MIN, CPS_MAX, CPS_INET, CPS_PAY, CPS_ACT,
						
				CPS_COEF, SYS_COUNT, KOB,
				
				PAY, CALC,				
				
				NOTE, UPDATES, ACT, INET,
				
				ROUND(CASE
					WHEN CLT_NAME = 'КГС корп.' AND CL_TERR = 'БГ' AND KGS >= 70 AND ISNULL(TO_CALC, 0) < CPS_MIN THEN CPS_MIN * KOB
					WHEN CLT_NAME = 'КГС корп.' AND CL_TERR = 'УТ' AND ISNULL(TO_CALC, 0) < CPS_MIN THEN CPS_MIN * KOB
					ELSE TO_CALC * KOB
				END, 0) AS TO_RESULT
			FROM
				(
					SELECT 
						TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, CLT_ID, CLT_NAME, KGS, PR_ID, PR_DATE,	CL_TERR,	
						
						CLIENT_TOTAL_PRICE, TO_COUNT, TO_PRICE, CPS_PERCENT, TO_CALC,
						
						CPS_MIN, CPS_MAX, CPS_INET, CPS_PAY, CPS_ACT,
								
						CPS_COEF, SYS_COUNT,
						CASE CPS_COEF 
							WHEN 1 THEN 
								CASE
									WHEN INET = 1 THEN 1
									WHEN CPS_MAX IS NOT NULL AND TO_CALC > CPS_MAX THEN 1
									ELSE
										(
											SELECT TOP 1 PC_VALUE 
											FROM dbo.PayCoefTable 
											WHERE SYS_COUNT BETWEEN PC_START AND PC_END
										)
								END
							ELSE 1
						END AS KOB,
						
						CONVERT(BIT, PAY) AS PAY, CALC,				
						
						NOTE, UPDATES, ACT, INET		
					FROM
						(
							SELECT 
								TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, CLT_ID, CLT_NAME, KGS, t.PR_ID, PR_DATE, CL_TERR,	
								
								CLIENT_TOTAL_PRICE, TO_COUNT, TO_PRICE, CPS_PERCENT, 
								
								CASE 
									WHEN CPS_PERCENT IS NOT NULL THEN TO_PRICE * CPS_PERCENT / 100 
									ELSE TO_PRICE
								END AS TO_CALC,
								
								CPS_MIN, CPS_MAX, CPS_INET, CPS_PAY, CPS_ACT,
										
								CPS_COEF, SYS_COUNT,	
								
								CASE 
									WHEN CPS_PAY = 0 THEN 1 
									ELSE PAY 
								END AS PAY, 
								CALC,				
								
								NOTE, UPDATES, ACT, INET
							FROM
								(
									SELECT 
										TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, PR_ID,
										CLT_ID, CLT_NAME, KGS, CL_TERR,
										TO_COUNT, SYS_COUNT,
										CASE
                                            -- ToDo очень грязный хардкод - общая стоимость одной ТО по Мировым судьям
                                            WHEN CL_ID = 10321 THEN 125973.5
                                            ELSE CLIENT_TOTAL_PRICE
                                        END AS CLIENT_TOTAL_PRICE,
										--CLIENT_TOTAL_PRICE,
										CPS_PERCENT, CPS_PAY, CPS_COEF, CPS_MIN, CPS_MAX, CPS_INET, CPS_ACT,
										CONVERT(BIT, ISNULL(PAY, 0)) AS PAY,
										CONVERT(BIT, 
											CASE
												WHEN CPS_ACT = 1 AND ACT <> 1 THEN 0
												ELSE 1
											END
											/*CASE 
												WHEN CPS_PAY = 1 AND PAY <> 1 THEN 0
												ELSE 1
											END*/
										) AS CALC,
										/*CASE
											WHEN TO_COUNT IS NULL OR TO_COUNT = 0 THEN CLIENT_TOTAL_PRICE
											ELSE CLIENT_TOTAL_PRICE / TO_COUNT
										END AS TO_PRICE,*/
										CASE
                                            -- ToDo очень грязный хардкод - общая стоимость одной ТО по Мировым судьям
                                            WHEN CL_ID = 10321 THEN 1085.98
											WHEN TO_COUNT IS NULL OR TO_COUNT = 0 THEN CLIENT_TOTAL_PRICE
											ELSE CLIENT_TOTAL_PRICE / TO_COUNT
										END AS TO_PRICE,				
										CONVERT(VARCHAR(MAX), '') AS NOTE,
										CONVERT(BIT, 0) AS HOLD,
										CONVERT(BIT, 1) AS UPDATES,
										CONVERT(BIT, ISNULL(ACT, 1)) AS ACT,
										CONVERT(BIT, 0) AS INET 
									FROM
										(

										/*
											общая сумма по ТО * %
										*/
										SELECT 
											TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, 
											a.CLT_ID, CLT_NAME, KGS, CL_TERR,
											NULL AS TO_COUNT,
											CASE
												WHEN
													ISNULL((
														SELECT COUNT(DISTINCT TD_ID_DISTR)
														FROM 
															dbo.TODistrTable z
															INNER JOIN dbo.DistrView y ON z.TD_ID_DISTR = y.DIS_ID
															INNER JOIN dbo.SystemTable x ON x.SYS_ID = y.SYS_ID
															INNER JOIN dbo.PeriodRegTable w ON w.REG_ID_SYSTEM = x.SYS_ID
																							AND REG_DISTR_NUM = DIS_NUM
																							AND REG_COMP_NUM = DIS_COMP_NUM
															INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
														WHERE z.TD_ID_TO = a.TO_ID AND w.REG_ID_PERIOD = c.PR_ID AND DS_REG = 0
													), 0) = 0
													THEN
														(
															SELECT COUNT(DISTINCT TD_ID_DISTR)
															FROM 
																dbo.TODistrTable z INNER JOIN
																dbo.ActDistrTable ON AD_ID_DISTR = TD_ID_DISTR INNER JOIN 
																dbo.ActTable ON AD_ID_ACT = ACT_ID		
															WHERE z.TD_ID_TO = a.TO_ID AND AD_ID_PERIOD = c.PR_ID
														) 
													ELSE
														(
															SELECT COUNT(DISTINCT TD_ID_DISTR)
															FROM 
																dbo.TODistrTable z
																INNER JOIN dbo.DistrView y ON z.TD_ID_DISTR = y.DIS_ID
																INNER JOIN dbo.SystemTable x ON x.SYS_ID = y.SYS_ID
																INNER JOIN dbo.PeriodRegTable w ON w.REG_ID_SYSTEM = x.SYS_ID
																								AND REG_DISTR_NUM = DIS_NUM
																								AND REG_COMP_NUM = DIS_COMP_NUM
																INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
															WHERE z.TD_ID_TO = a.TO_ID AND w.REG_ID_PERIOD = c.PR_ID AND DS_REG = 0
														) 
											END AS SYS_COUNT,
											c.PR_ID, 
											ISNULL(
												(
													SELECT SUM(AD_PRICE)
													FROM 
														dbo.ActTable c
														INNER JOIN dbo.ActDistrTable d ON d.AD_ID_ACT = c.ACT_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = AD_ID_DISTR AND TD_ID_TO = a.TO_ID
													WHERE AD_ID_PERIOD = PR_ID AND ACT_ID_CLIENT = CL_ID
												),
												(
													SELECT SUM(BD_PRICE)
													FROM 
														dbo.BillTable c
														INNER JOIN dbo.BillDistrTable d ON d.BD_ID_BILL = c.BL_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = BD_ID_DISTR AND TD_ID_TO = a.TO_ID
													WHERE BL_ID_PERIOD = PR_ID AND BL_ID_CLIENT = CL_ID
												)
												) AS CLIENT_TOTAL_PRICE,
											CPS_PERCENT,
											CPS_PAY, CPS_COEF, CPS_MIN, CPS_MAX, CPS_INET, CPS_ACT,
											CASE 
												WHEN EXISTS
													(
														SELECT *
														FROM 
															dbo.TOTable t INNER JOIN
															dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
															dbo.DistrView ON DIS_ID = TD_ID_DISTR INNER JOIN
															dbo.BillRestView ON BD_ID_DISTR = DIS_ID AND BL_ID_CLIENT = TO_ID_CLIENT
														WHERE t.TO_ID = a.TO_ID
															AND BL_ID_PERIOD = PR_ID
															AND BD_REST > 0
													) THEN 0
												ELSE 1 
											END AS PAY,
											CASE 
												WHEN EXISTS
													(
														SELECT *
														FROM 
															dbo.TOTable t INNER JOIN
															dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN															
															dbo.ActIXView WITH(NOEXPAND) ON AD_ID_DISTR = TD_ID_DISTR AND ACT_ID_CLIENT = TO_ID_CLIENT
														WHERE t.TO_ID = a.TO_ID
															AND AD_ID_PERIOD = PR_ID
													) THEN 1
												ELSE 0 
											END AS ACT
										FROM 
											#client a
											INNER JOIN dbo.ClientTypeTable b ON a.CLT_ID = b.CLT_ID
											INNER JOIN dbo.CourierPaySettingsTable d ON d.CPS_ID_TYPE = b.CLT_ID
											CROSS APPLY
												(
													SELECT AD_ID_PERIOD AS PR_ID
													FROM 
														dbo.ActTable c
														INNER JOIN dbo.ActDistrTable d ON d.AD_ID_ACT = c.ACT_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = AD_ID_DISTR AND TD_ID_TO = a.TO_ID
														INNER JOIN dbo.PeriodTable ON PR_ID = AD_ID_PERIOD
													WHERE PR_DATE >= '20140601' AND PR_DATE <= @PR_BEGIN AND ACT_ID_CLIENT = CL_ID													
													
													UNION
													
													SELECT @PERIOD
													
													/*
													SELECT AD_ID_PERIOD AS PR_ID
													FROM 
														dbo.ActTable c
														INNER JOIN dbo.ActDistrTable d ON d.AD_ID_ACT = c.ACT_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = AD_ID_DISTR AND TD_ID_TO = a.TO_ID
													WHERE ACT_DATE BETWEEN @PR_BEGIN AND @PR_END AND ACT_ID_CLIENT = CL_ID
													
													UNION
													
													SELECT @PERIOD
													
													UNION
													
													SELECT ID_ID_PERIOD AS PR_ID
													FROM 
														dbo.IncomeTable c
														INNER JOIN dbo.IncomeDistrTable d ON d.ID_ID_INCOME = c.IN_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = ID_ID_DISTR AND TD_ID_TO = a.TO_ID
														INNER JOIN dbo.PeriodTable ON ID_ID_PERIOD = PR_ID
													WHERE IN_DATE BETWEEN @PR_BEGIN AND @PR_END AND IN_ID_CLIENT = CL_ID AND PR_DATE < @PR_BEGIN
													*/
												) AS c
										WHERE CPS_SOURCE IN (1, 4)
										GROUP BY TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, c.PR_ID, CLT_NAME, CPS_PERCENT, CPS_PAY, CPS_COEF, CPS_MIN, CPS_MAX, CPS_INET, KGS, a.CLT_ID, CL_TERR, CPS_ACT

										/*
											фиксированная сумма за клиента
										*/

										UNION ALL

										SELECT 
											TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, 
											a.CLT_ID, CLT_NAME, KGS, CL_TERR,
											NULL AS TO_COUNT,
											(
												SELECT COUNT(*)
												FROM 
													dbo.TODistrTable z
													INNER JOIN dbo.DistrView y ON z.TD_ID_DISTR = y.DIS_ID
													INNER JOIN dbo.SystemTable x ON x.SYS_ID = y.SYS_ID
													INNER JOIN dbo.PeriodRegTable w ON w.REG_ID_SYSTEM = x.SYS_ID
																					AND REG_DISTR_NUM = DIS_NUM
																					AND REG_COMP_NUM = DIS_COMP_NUM
													INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
												WHERE z.TD_ID_TO = a.TO_ID AND w.REG_ID_PERIOD = @PERIOD AND DS_REG = 0
											) AS SYS_COUNT,
											@PERIOD AS PR_ID, 
											CPS_FIXED AS TOTAL_PRICE,
											CPS_PERCENT AS COUR_PERCENT,
											CPS_PAY, CPS_COEF, CPS_MIN, CPS_MAX, CPS_INET, CPS_ACT,
											NULL AS PAY,
											NULL AS ACT
										FROM 
											#client a
											INNER JOIN dbo.ClientTypeTable b ON a.CLT_ID = b.CLT_ID
											INNER JOIN dbo.CourierPaySettingsTable d ON d.CPS_ID_TYPE = b.CLT_ID	
										WHERE CPS_SOURCE IN (2)
										GROUP BY TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, CLT_NAME, CPS_PERCENT, CPS_PAY, CPS_COEF, CPS_MIN, CPS_MAX, CPS_INET, KGS, CPS_FIXED, a.CLT_ID, CL_TERR, CPS_ACT

										UNION ALL

										/*
											общая сумма по клиенту / кол-во ТО
										*/
										SELECT 
											TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, 
											a.CLT_ID, CLT_NAME, KGS, CL_TERR,
											CASE
												WHEN 
													(												
														SELECT COUNT(DISTINCT TO_ID)
														FROM 
															dbo.TOTable INNER JOIN
															dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
															dbo.DistrView ON DIS_ID = TD_ID_DISTR INNER JOIN
															dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
																		AND DIS_NUM = REG_DISTR_NUM
																		AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
															dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
														WHERE DS_REG = 0
															AND REG_ID_PERIOD = PR_ID
															AND TO_ID_CLIENT = a.CL_ID 
													) = 0 THEN
													(												
														SELECT COUNT(DISTINCT TO_ID)
														FROM 
															dbo.TOTable INNER JOIN
															dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
															dbo.ActDistrTable ON AD_ID_DISTR = TD_ID_DISTR INNER JOIN 
															dbo.ActTable ON AD_ID_ACT = ACT_ID														
														WHERE AD_ID_PERIOD = PR_ID
															AND TO_ID_CLIENT = a.CL_ID 
													)
												ELSE
													(												
														SELECT COUNT(DISTINCT TO_ID)
														FROM 
															dbo.TOTable INNER JOIN
															dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
															dbo.DistrView ON DIS_ID = TD_ID_DISTR INNER JOIN
															dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
																		AND DIS_NUM = REG_DISTR_NUM
																		AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
															dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
														WHERE DS_REG = 0
															AND REG_ID_PERIOD = PR_ID
															AND TO_ID_CLIENT = a.CL_ID 
													)
											END AS TO_COUNT,
											CASE
												WHEN 
													(
														SELECT COUNT(DISTINCT TD_ID_DISTR)
														FROM 
															dbo.TODistrTable z
															INNER JOIN dbo.DistrView y ON z.TD_ID_DISTR = y.DIS_ID
															INNER JOIN dbo.SystemTable x ON x.SYS_ID = y.SYS_ID
															INNER JOIN dbo.PeriodRegTable w ON w.REG_ID_SYSTEM = x.SYS_ID
																							AND REG_DISTR_NUM = DIS_NUM
																							AND REG_COMP_NUM = DIS_COMP_NUM
															INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
														WHERE z.TD_ID_TO = a.TO_ID AND w.REG_ID_PERIOD = c.PR_ID AND DS_REG = 0
													) = 0
													THEN
													(
														SELECT COUNT(DISTINCT TD_ID_DISTR)
														FROM 
															dbo.TODistrTable z INNER JOIN
															dbo.ActDistrTable ON AD_ID_DISTR = TD_ID_DISTR INNER JOIN 
															dbo.ActTable ON AD_ID_ACT = ACT_ID			
														WHERE z.TD_ID_TO = a.TO_ID AND AD_ID_PERIOD = c.PR_ID 
													)
													ELSE
													(
														SELECT COUNT(DISTINCT TD_ID_DISTR)
														FROM 
															dbo.TODistrTable z
															INNER JOIN dbo.DistrView y ON z.TD_ID_DISTR = y.DIS_ID
															INNER JOIN dbo.SystemTable x ON x.SYS_ID = y.SYS_ID
															INNER JOIN dbo.PeriodRegTable w ON w.REG_ID_SYSTEM = x.SYS_ID
																							AND REG_DISTR_NUM = DIS_NUM
																							AND REG_COMP_NUM = DIS_COMP_NUM
															INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
														WHERE z.TD_ID_TO = a.TO_ID AND w.REG_ID_PERIOD = c.PR_ID AND DS_REG = 0
													)
											END AS SYS_COUNT,
											c.PR_ID, 
											ISNULL(
												(
													SELECT SUM(AD_PRICE)
													FROM 
														dbo.ActTable c
														INNER JOIN dbo.ActDistrTable d ON d.AD_ID_ACT = c.ACT_ID
													WHERE ACT_DATE BETWEEN @PR_BEGIN AND @PR_END AND ACT_ID_CLIENT = CL_ID
												),
												(
													SELECT SUM(BD_PRICE)
													FROM 
														dbo.BillTable c
														INNER JOIN dbo.BillDistrTable d ON d.BD_ID_BILL = c.BL_ID
														--INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = BD_ID_DISTR AND TD_ID_TO = a.TO_ID
													WHERE BL_ID_PERIOD = @PERIOD AND BL_ID_CLIENT = CL_ID
												)
												) AS TOTAL_PRICE,
											CPS_PERCENT AS COUR_PERCENT,
											CPS_PAY, CPS_COEF, CPS_MIN, CPS_MAX, CPS_INET, CPS_ACT,
											CASE 
												WHEN EXISTS
													(
														SELECT *
														FROM 
															dbo.TOTable t INNER JOIN
															dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
															dbo.DistrView ON DIS_ID = TD_ID_DISTR INNER JOIN
															dbo.BillRestView ON BD_ID_DISTR = DIS_ID AND BL_ID_CLIENT = TO_ID_CLIENT
														WHERE t.TO_ID = a.TO_ID
															AND BL_ID_PERIOD = PR_ID
															AND BD_REST > 0
													) THEN 0
												ELSE 1 
											END AS PAY,
											CASE 
												WHEN EXISTS
													(
														SELECT *
														FROM 
															dbo.TOTable t INNER JOIN
															dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN															
															dbo.ActIXView WITH(NOEXPAND) ON AD_ID_DISTR = TD_ID_DISTR AND ACT_ID_CLIENT = TO_ID_CLIENT
														WHERE t.TO_ID = a.TO_ID
															AND AD_ID_PERIOD = PR_ID
													) THEN 1
												ELSE 0 
											END AS ACT
										FROM 
											#client a
											INNER JOIN dbo.ClientTypeTable b ON a.CLT_ID = b.CLT_ID
											INNER JOIN dbo.CourierPaySettingsTable d ON d.CPS_ID_TYPE = b.CLT_ID
											CROSS APPLY
												(
													SELECT AD_ID_PERIOD AS PR_ID
													FROM 
														dbo.ActTable c
														INNER JOIN dbo.ActDistrTable d ON d.AD_ID_ACT = c.ACT_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = AD_ID_DISTR AND TD_ID_TO = a.TO_ID
														INNER JOIN dbo.PeriodTable ON PR_ID = AD_ID_PERIOD
													WHERE PR_DATE >= '20140601' AND PR_DATE <= @PR_BEGIN AND ACT_ID_CLIENT = CL_ID													
													
													UNION
													
													SELECT @PERIOD
													
													/*
													SELECT AD_ID_PERIOD AS PR_ID
													FROM 
														dbo.ActTable c
														INNER JOIN dbo.ActDistrTable d ON d.AD_ID_ACT = c.ACT_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = AD_ID_DISTR AND TD_ID_TO = a.TO_ID
													WHERE ACT_DATE BETWEEN @PR_BEGIN AND @PR_END AND ACT_ID_CLIENT = CL_ID
													
													UNION
													
													SELECT @PERIOD
													
													UNION
													
													SELECT ID_ID_PERIOD AS PR_ID
													FROM 
														dbo.IncomeTable c
														INNER JOIN dbo.IncomeDistrTable d ON d.ID_ID_INCOME = c.IN_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = ID_ID_DISTR AND TD_ID_TO = a.TO_ID
														INNER JOIN dbo.PeriodTable ON ID_ID_PERIOD = PR_ID
													WHERE IN_DATE BETWEEN @PR_BEGIN AND @PR_END AND IN_ID_CLIENT = CL_ID AND PR_DATE < @PR_BEGIN
													*/
												) AS c
										WHERE CPS_SOURCE IN (3, 5)
											/*
											проверяем, что за этот месяц клиент еще не расчитывался. Иначе - берем данные с расчитанного клиента (сумма, кол-во ТО и т.д.)
											*/
											AND NOT EXISTS
												(
													SELECT *
													FROM Salary.ServiceDetail z
													WHERE a.CL_ID = z.ID_CLIENT
														AND z.ID_PERIOD = PR_ID
												)
										GROUP BY TO_ID, CL_ID, TO_NAME, CL_PSEDO, CT_ID, CT_NAME, c.PR_ID, CLT_NAME, CPS_PERCENT, CPS_PAY, CPS_COEF, CPS_MIN, CPS_MAX, CPS_INET, KGS, a.CLT_ID, CL_TERR, CPS_ACT
										
										UNION ALL

										/*
											общая сумма по клиенту / кол-во ТО
										*/
										SELECT 
											a.TO_ID, CL_ID, a.TO_NAME, a.CL_PSEDO, CT_ID, a.CT_NAME, 
											a.CLT_ID, CLT_NAME, a.KGS, a.CL_TERR,
											TO_COUNT,
											(
												SELECT COUNT(*)
												FROM 
													dbo.TODistrTable z
													INNER JOIN dbo.DistrView y ON z.TD_ID_DISTR = y.DIS_ID
													INNER JOIN dbo.SystemTable x ON x.SYS_ID = y.SYS_ID
													INNER JOIN dbo.PeriodRegTable w ON w.REG_ID_SYSTEM = x.SYS_ID
																					AND REG_DISTR_NUM = DIS_NUM
																					AND REG_COMP_NUM = DIS_COMP_NUM
													INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
												WHERE z.TD_ID_TO = a.TO_ID AND w.REG_ID_PERIOD = c.PR_ID AND DS_REG = 0
											) AS SYS_COUNT,
											c.PR_ID, 
											z.CLIENT_TOTAL_PRICE AS TOTAL_PRICE,
											d.CPS_PERCENT AS COUR_PERCENT,
											d.CPS_PAY, d.CPS_COEF, d.CPS_MIN, d.CPS_MAX, d.CPS_INET, d.CPS_ACT,
											CASE 
												WHEN EXISTS
													(
														SELECT *
														FROM 
															dbo.TOTable t INNER JOIN
															dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
															dbo.DistrView ON DIS_ID = TD_ID_DISTR INNER JOIN
															dbo.BillRestView ON BD_ID_DISTR = DIS_ID AND BL_ID_CLIENT = TO_ID_CLIENT
														WHERE t.TO_ID = a.TO_ID
															AND BL_ID_PERIOD = PR_ID
															AND BD_REST > 0
													) THEN 0
												ELSE 1 
											END AS PAY,
											CASE 
												WHEN EXISTS
													(
														SELECT *
														FROM 
															dbo.TOTable t INNER JOIN
															dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN															
															dbo.ActIXView WITH(NOEXPAND) ON AD_ID_DISTR = TD_ID_DISTR AND ACT_ID_CLIENT = TO_ID_CLIENT
														WHERE t.TO_ID = a.TO_ID
															AND AD_ID_PERIOD = PR_ID
													) THEN 1
												ELSE 0 
											END AS ACT
										FROM 
											#client a
											INNER JOIN dbo.ClientTypeTable b ON a.CLT_ID = b.CLT_ID
											INNER JOIN dbo.CourierPaySettingsTable d ON d.CPS_ID_TYPE = b.CLT_ID
											CROSS APPLY
												(
													SELECT AD_ID_PERIOD AS PR_ID
													FROM 
														dbo.ActTable c
														INNER JOIN dbo.ActDistrTable d ON d.AD_ID_ACT = c.ACT_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = AD_ID_DISTR AND TD_ID_TO = a.TO_ID
														INNER JOIN dbo.PeriodTable ON PR_ID = AD_ID_PERIOD
													WHERE PR_DATE >= '20140601' AND PR_DATE <= @PR_BEGIN AND ACT_ID_CLIENT = CL_ID													
													
													UNION
													
													SELECT @PERIOD
													
													/*
													SELECT AD_ID_PERIOD AS PR_ID
													FROM 
														dbo.ActTable c
														INNER JOIN dbo.ActDistrTable d ON d.AD_ID_ACT = c.ACT_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = AD_ID_DISTR AND TD_ID_TO = a.TO_ID
													WHERE ACT_DATE BETWEEN @PR_BEGIN AND @PR_END AND ACT_ID_CLIENT = CL_ID
													
													UNION
													
													SELECT @PERIOD
													
													UNION
													
													SELECT ID_ID_PERIOD AS PR_ID
													FROM 
														dbo.IncomeTable c
														INNER JOIN dbo.IncomeDistrTable d ON d.ID_ID_INCOME = c.IN_ID
														INNER JOIN dbo.TODistrTable f ON f.TD_ID_DISTR = ID_ID_DISTR AND TD_ID_TO = a.TO_ID
														INNER JOIN dbo.PeriodTable ON ID_ID_PERIOD = PR_ID
													WHERE IN_DATE BETWEEN @PR_BEGIN AND @PR_END AND IN_ID_CLIENT = CL_ID AND PR_DATE < @PR_BEGIN
													*/
												) AS c
											INNER JOIN Salary.ServiceDetail z ON a.CL_ID = z.ID_CLIENT AND z.ID_PERIOD = PR_ID
										WHERE CPS_SOURCE IN (3, 5)
										GROUP BY a.TO_ID, a.CL_ID, a.TO_NAME, TO_COUNT, CLIENT_TOTAL_PRICE, a.CL_PSEDO, CT_ID, a.CT_NAME, c.PR_ID, CLT_NAME, d.CPS_PERCENT, d.CPS_PAY, d.CPS_COEF, d.CPS_MIN, d.CPS_MAX, d.CPS_INET, a.KGS, a.CLT_ID, a.CL_TERR, d.CPS_ACT
									) AS o_O
								) AS o_O
							INNER JOIN dbo.PeriodTable t ON t.PR_ID = o_O.PR_ID

							WHERE NOT EXISTS
								(
									SELECT *
									FROM Salary.ServiceDetail z
									WHERE z.TO_ID = o_O.TO_ID
										AND z.ID_PERIOD = t.PR_ID
								) AND 
								CASE 
									WHEN CT_NAME = 'Ольга' AND PR_DATE < '20141001' THEN 0
									WHEN CL_PSEDO = 'Трансминвод' AND PR_DATE = '20140601' THEN 0
									WHEN CL_PSEDO = 'Восток Инвест Сталь' AND PR_DATE <= '20141001' THEN 0
									WHEN CL_PSEDO = 'Восток-Сервис' AND PR_DATE = '20140601' THEN 0
									WHEN CL_PSEDO = 'Кристалл 1' AND PR_DATE = '20140601' THEN 0
									WHEN CL_PSEDO = 'Аптека №5' AND PR_DATE = '20140601' THEN 0
									WHEN CL_PSEDO = 'Хлебокомбинат Арс.' AND PR_DATE = '20140601' THEN 0
									WHEN CL_PSEDO = 'Примтеплоэнерго' AND PR_DATE < '20170101' THEN 0
									WHEN CL_PSEDO = 'Деп-т службы зан-ти' AND PR_DATE < '20151201' THEN 0
									WHEN CT_NAME = 'Большой камень' AND PR_DATE <= '20160901' THEN 0
									WHEN CL_PSEDO = 'Следств.упр. при прокуратуре' AND PR_DATE = '20160801' THEN 0
									WHEN PR_DATE <= DATEADD(MONTH, -8, @PR_BEGIN) THEN 0
									ELSE 1
								END = 1
						) AS o_O
				) AS o_O
		) AS o_O
	ORDER BY CT_NAME, CL_PSEDO, TO_NAME, PR_DATE
END
