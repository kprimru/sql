USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[PERSONAL_SALARY_DETAIL_CALC_SELECT]
	@PER_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	/*
	DECLARE @BC	TABLE (
				ID_ID		UNIQUEIDENTIFIER,
				BC_ID		UNIQUEIDENTIFIER, 
				BC_PERCENT	DECIMAL(8, 4),
				BC_PRICE	MONEY
				)
	*/

	SELECT 
		ID_ID, IN_DATE, CL_NAME, ID_FULL_DATE,
		ID_COUNT, ID_DEL_PRICE, ID_MON_CNT, ID_SUP_MONTH, 
		ID_PREPAY, ID_COMMENT, SYS_SHORT, NT_NAME, TT_NAME, PER_NAME, IP_PERCENT,
		CAST(ROUND(ID_SALARY_NDS, 2) AS MONEY)  AS SL_PRICE,
		CAST(ROUND(CAST(ID_SALARY_NDS * IP_PERCENT / 100 AS MONEY), 2) AS MONEY) AS SL_SUM,
		CAST(ROUND(CAST(ID_SALARY_NDS * IP_PERCENT * ID_COUNT / 100 AS MONEY), 2) AS MONEY) AS SL_TOTAL,
		ID_INSTALLED, ID_ACT, SL_SECOND, CONVERT(SMALLDATETIME, NULL) AS SL_PAY_DATE
	FROM 
		(	
			SELECT
				a.ID_ID, IN_DATE, CL_NAME, ID_FULL_DATE,
				ID_COUNT, ID_DEL_PRICE, ID_MON_CNT, ID_SUP_MONTH, 
				ID_PREPAY, ID_COMMENT, SYS_SHORT, NT_NAME, TT_NAME, PER_NAME, 
				CASE 
					WHEN 
						(
							SELECT SUM(IP_PERCENT) 
							FROM Income.IncomePersonal z
							WHERE z.IP_ID_INCOME = a.ID_ID
						) >= 100 THEN CONVERT(DECIMAL(8, 4), IP_PERCENT / 
						(
							SELECT SUM(IP_PERCENT) 
							FROM Income.IncomePersonal z
							WHERE z.IP_ID_INCOME = a.ID_ID
						) * 100)
					ELSE IP_PERCENT
				END AS IP_PERCENT,
				ID_SALARY_NDS,
				CAST(ROUND(ID_SALARY_NDS, 2) AS MONEY)  AS SL_PRICE,
				
				CASE 
					WHEN EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INSTALL IN
								( 
									SELECT IND_ID_INSTALL
									FROM Install.InstallDetail 
									WHERE IND_ID_INCOME = a.ID_ID 
										AND (IND_INSTALL_DATE IS NULL OR IND_ID_PERSONAL IS NULL)
								)
								
						) OR
						NOT EXISTS(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INCOME = a.ID_ID					
						)	THEN CAST (0 AS BIT)
					ELSE CAST (1 AS BIT)
				END AS ID_INSTALLED,
				CASE 
					WHEN EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INSTALL IN
								( 
									SELECT IND_ID_INSTALL
									FROM Install.InstallDetail 
									WHERE IND_ID_INCOME = a.ID_ID 
										AND IND_ACT_RETURN IS NULL 
								)
						) OR
						NOT EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INCOME = a.ID_ID
						)	THEN CAST (0 AS BIT)
					ELSE CAST (1 AS BIT)
				END AS ID_ACT,
				CONVERT(BIT, 0) AS SL_SECOND
			FROM	
				Income.IncomeFullView a INNER JOIN
				Income.IncomePersonalView b ON a.ID_ID = b.ID_ID
			WHERE PER_ID_MASTER = @PER_ID 
				AND ID_REPAYED = 0 
				AND ID_REPAY = 0
				AND ID_CALC = 1 AND
				NOT EXISTS
				(
					SELECT *
					FROM	
						Salary.PersonalSalary INNER JOIN
						Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
					WHERE PS_ID_PERSONAL = @PER_ID AND PSD_ID_INCOME = a.ID_ID
				)
		) AS a
	
	UNION ALL
	
	SELECT 
		ID_ID, IN_DATE, CL_NAME, ID_FULL_DATE,
		ID_COUNT, ID_DEL_PRICE, ID_MON_CNT, ID_SUP_MONTH, 
		ID_PREPAY, ID_COMMENT, SYS_SHORT, NT_NAME, TT_NAME, PER_NAME, IP_PERCENT,
		CAST(ROUND(ID_SALARY_NDS, 2) AS MONEY)  AS SL_PRICE,
		CAST(ROUND(CAST(ID_SALARY_NDS * IP_PERCENT / 100 AS MONEY), 2) AS MONEY) AS SL_SUM,
		CAST(ROUND(CAST(ID_SALARY_NDS * IP_PERCENT * ID_COUNT / 100 AS MONEY), 2) AS MONEY) AS SL_TOTAL,
		ID_INSTALLED, ID_ACT, SL_SECOND, CONVERT(SMALLDATETIME, NULL) AS SL_PAY_DATE
	FROM 
		(	
			SELECT
				a.ID_ID, IN_DATE, CL_NAME, ID_FULL_DATE,
				ID_COUNT, ID_DEL_PRICE, ID_MON_CNT, ID_SUP_MONTH, 
				ID_PREPAY, ID_COMMENT, SYS_SHORT, NT_NAME, TT_NAME, PER_NAME, 
				CASE 
					WHEN 
						(
							SELECT SUM(IP_PERCENT2) 
							FROM Income.IncomePersonal z
							WHERE z.IP_ID_INCOME = a.ID_ID
						) >= 100 THEN CONVERT(DECIMAL(8, 4), IP_PERCENT2 / 
						(
							SELECT SUM(IP_PERCENT2) 
							FROM Income.IncomePersonal z
							WHERE z.IP_ID_INCOME = a.ID_ID
						) * 100)
					ELSE IP_PERCENT2
				END AS IP_PERCENT,
				ID_SALARY_NDS,
				CAST(ROUND(ID_SALARY_NDS, 2) AS MONEY)  AS SL_PRICE,
				
				CASE 
					WHEN EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INSTALL IN
								( 
									SELECT IND_ID_INSTALL
									FROM Install.InstallDetail 
									WHERE IND_ID_INCOME = a.ID_ID 
										AND (IND_INSTALL_DATE IS NULL OR IND_ID_PERSONAL IS NULL)
								)
								
						) OR
						NOT EXISTS(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INCOME = a.ID_ID					
						)	THEN CAST (0 AS BIT)
					ELSE CAST (1 AS BIT)
				END AS ID_INSTALLED,
				CASE 
					WHEN EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INSTALL IN
								( 
									SELECT IND_ID_INSTALL
									FROM Install.InstallDetail 
									WHERE IND_ID_INCOME = a.ID_ID 
										AND IND_ACT_RETURN IS NULL 
								)
						) OR
						NOT EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INCOME = a.ID_ID
						)	THEN CAST (0 AS BIT)
					ELSE CAST (1 AS BIT)
				END AS ID_ACT,
				CONVERT(BIT, 1) AS SL_SECOND
			FROM	
				Income.IncomeFullView a INNER JOIN
				Income.IncomePersonalView b ON a.ID_ID = b.ID_ID
			WHERE PER_ID_MASTER = @PER_ID 
				AND ID_REPAYED = 0 
				AND ID_REPAY = 0
				AND ID_CALC = 1
				AND ISNULL(IP_PERCENT2, 0) <> 0
				AND EXISTS
				(
					SELECT *
					FROM	
						Salary.PersonalSalary INNER JOIN
						Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
					WHERE PS_ID_PERSONAL = @PER_ID AND PSD_ID_INCOME = a.ID_ID
				)
				AND NOT EXISTS
				(
					SELECT *
					FROM	
						Salary.PersonalSalary INNER JOIN
						Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
					WHERE PS_ID_PERSONAL = @PER_ID AND PSD_ID_INCOME = a.ID_ID AND PSD_SECOND = 1
				)
		) AS a
	
	/*	
	UNION ALL
	
	SELECT 
		a.ID_ID, IN_DATE, CL_NAME, ID_FULL_DATE,
		ID_COUNT, ID_DEL_PRICE, ID_MON_CNT, ID_SUP_MONTH, 
		ID_PREPAY, ID_COMMENT, SYS_SHORT, NT_NAME, TT_NAME, PER_NAME, IP_PERCENT,
		CAST(ROUND(ID_SALARY_NDS, 2) AS MONEY)  AS SL_PRICE,
		CAST(ROUND(CAST(ID_SALARY_NDS * IP_PERCENT / 100 AS MONEY), 2) AS MONEY) AS SL_SUM,
		CAST(ROUND(CAST(ID_SALARY_NDS * IP_PERCENT * ID_COUNT / 100 AS MONEY), 2) AS MONEY) AS SL_TOTAL,
		CASE 
			WHEN EXISTS
				(
					SELECT *
					FROM Install.InstallDetail
					WHERE IND_ID_INSTALL IN
						( 
							SELECT IND_ID_INSTALL
							FROM Install.InstallDetail 
							WHERE IND_ID_INCOME = a.ID_ID 
								AND (IND_INSTALL_DATE IS NULL OR IND_ID_PERSONAL IS NULL)
						)
						
				) OR
				NOT EXISTS(
					SELECT *
					FROM Install.InstallDetail
					WHERE IND_ID_INCOME = a.ID_ID					
				)	THEN CAST (0 AS BIT)
			ELSE CAST (1 AS BIT)
		END AS ID_INSTALLED,
		CASE 
			WHEN EXISTS
				(
					SELECT *
					FROM Install.InstallDetail
					WHERE IND_ID_INSTALL IN
						( 
							SELECT IND_ID_INSTALL
							FROM Install.InstallDetail 
							WHERE IND_ID_INCOME = a.ID_ID 
								AND IND_ACT_RETURN IS NULL 
						)
				) OR
				NOT EXISTS
				(
					SELECT *
					FROM Install.InstallDetail
					WHERE IND_ID_INCOME = a.ID_ID
				)	THEN CAST (0 AS BIT)
			ELSE CAST (1 AS BIT)
		END AS ID_ACT,
		CONVERT(BIT, 1) AS SL_SECOND, CONVERT(SMALLDATETIME, NULL) AS SL_PAY_DATE
	FROM 
		(	
			SELECT
				a.ID_ID, IN_DATE, CL_NAME, ID_FULL_DATE,
				ID_COUNT, ID_DEL_PRICE, ID_MON_CNT, ID_SUP_MONTH, 
				ID_PREPAY, ID_COMMENT, SYS_SHORT, NT_NAME, TT_NAME, PER_NAME, 
				CONVERT(DECIMAL(8, 4), (
							SELECT SUM(IP_PERCENT) 
							FROM Income.IncomePersonal z
							WHERE z.IP_ID_INCOME = a.ID_ID
								AND z.IP_ID_PERSONAL = PER_ID_MASTER
						) - IP_PERCENT / 
						(
							SELECT SUM(IP_PERCENT) 
							FROM Income.IncomePersonal z
							WHERE z.IP_ID_INCOME = a.ID_ID
						) * 100) IP_PERCENT,
				ID_SALARY_NDS,
				CAST(ROUND(ID_SALARY_NDS, 2) AS MONEY)  AS SL_PRICE,
				
				CASE 
					WHEN EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INSTALL IN
								( 
									SELECT IND_ID_INSTALL
									FROM Install.InstallDetail 
									WHERE IND_ID_INCOME = a.ID_ID 
										AND (IND_INSTALL_DATE IS NULL OR IND_ID_PERSONAL IS NULL)
								)
								
						) OR
						NOT EXISTS(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INCOME = a.ID_ID					
						)	THEN CAST (0 AS BIT)
					ELSE CAST (1 AS BIT)
				END AS ID_INSTALLED,
				CASE 
					WHEN EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INSTALL IN
								( 
									SELECT IND_ID_INSTALL
									FROM Install.InstallDetail 
									WHERE IND_ID_INCOME = a.ID_ID 
										AND IND_ACT_RETURN IS NULL 
								)
						) OR
						NOT EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INCOME = a.ID_ID
						)	THEN CAST (0 AS BIT)
					ELSE CAST (1 AS BIT)
				END AS ID_ACT,
				CONVERT(BIT, 0) AS SL_SECOND
			FROM	
				Income.IncomeFullView a INNER JOIN
				Income.IncomePersonalView b ON a.ID_ID = b.ID_ID
			WHERE PER_ID_MASTER = @PER_ID 
				AND ID_REPAYED = 0 
				AND ID_REPAY = 0
				AND ID_CALC = 1 
				AND (
							SELECT SUM(IP_PERCENT) 
							FROM Income.IncomePersonal z
							WHERE z.IP_ID_INCOME = a.ID_ID
						) >= 100
						AND
						EXISTS
		(
			SELECT *
			FROM	
				Salary.PersonalSalary INNER JOIN
				Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
			WHERE PS_ID_PERSONAL = @PER_ID AND PSD_ID_INCOME = a.ID_ID AND PSD_SECOND = 0
		)
		AND
				NOT EXISTS
				(
					SELECT *
					FROM	
						Salary.PersonalSalary INNER JOIN
						Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
					WHERE PS_ID_PERSONAL = @PER_ID AND PSD_ID_INCOME = a.ID_ID AND PSD_SECOND = 1
				)
		) AS a
		*/
	
		
END
