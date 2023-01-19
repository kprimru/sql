USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[SALARY_UNCALC_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[SALARY_UNCALC_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Salary].[SALARY_UNCALC_SELECT]
	@PT_ID	UNIQUEIDENTIFIER,
	@DT		SMALLDATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
		ROW_NUMBER() OVER (ORDER BY PER_NAME) AS NUM,
		a.ID_ID, IN_DATE, PER_NAME, CL_NAME, a.SYS_SHORT, DT_SHORT, NT_NEW_NAME,
		ID_COMMENT, ID_COUNT, ID_MON_CNT, 
		CASE
			WHEN IN_DATE < '20130801' THEN IP_PERCENT
			ELSE
				CASE
					WHEN (
							SELECT SUM(IP_PERCENT)
							FROM Income.IncomePersonal z
							WHERE z.IP_ID_INCOME = a.ID_ID
						) >= 100
						AND EXISTS
						(
							SELECT *
							FROM
								Salary.PersonalSalary INNER JOIN
								Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
							WHERE PS_ID_PERSONAL = b.PER_ID_MASTER AND PSD_ID_INCOME = a.ID_ID AND PSD_SECOND = 0
						)
						AND
						NOT EXISTS
						(
							SELECT *
							FROM
								Salary.PersonalSalary INNER JOIN
								Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
							WHERE PS_ID_PERSONAL = b.PER_ID_MASTER AND PSD_ID_INCOME = a.ID_ID AND PSD_SECOND = 1
						) THEN
							(
								SELECT SUM(IP_PERCENT)
								FROM Income.IncomePersonal z
								WHERE z.IP_ID_INCOME = a.ID_ID
									AND z.IP_ID_PERSONAL = b.PER_ID_MASTER
							) - IP_PERCENT /
							(
								SELECT SUM(IP_PERCENT)
								FROM Income.IncomePersonal z
								WHERE z.IP_ID_INCOME = a.ID_ID
							) * 100
					ELSE
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
						END
				END
		END AS IP_PERCENT,
		'' +
		CASE
			WHEN ID_FULL_DATE IS NULL THEN '/Нет полной оплаты/'
			ELSE ''
		END +
		CASE
			WHEN NOT EXISTS
				(
					SELECT *
					FROM Install.InstallDetail
					WHERE IND_ID_INCOME = a.ID_ID
						AND IND_INSTALL_DATE IS NOT NULL
				) THEN '/Не произведена установка/'
			ELSE ''
		END +
		CASE
			WHEN NOT EXISTS
				(
					SELECT *
					FROM Install.InstallDetail
					WHERE IND_ID_INCOME = a.ID_ID
						AND IND_ACT_RETURN IS NOT NULL
				) THEN '/Не вернулись акты/'
			ELSE ''
		END
		+
		CASE
			WHEN
				(
					SELECT SUM(IP_PERCENT2)
					FROM Income.IncomePersonal z
					WHERE z.IP_ID_INCOME = a.ID_ID
				) > 0
				AND
				EXISTS
				(
					SELECT *
					FROM
						Salary.PersonalSalary INNER JOIN
						Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
					WHERE PS_ID_PERSONAL = b.PER_ID_MASTER AND PSD_ID_INCOME = a.ID_ID AND PSD_SECOND = 0
				)
				AND
				NOT EXISTS
				(
					SELECT *
					FROM
						Salary.PersonalSalary INNER JOIN
						Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
					WHERE PS_ID_PERSONAL = b.PER_ID_MASTER AND PSD_ID_INCOME = a.ID_ID AND PSD_SECOND = 1
				)
				THEN '/Не расчитана вторая часть ЗП/'
			ELSE ''
		END



		AS SL_REASON
	FROM
		Income.IncomeFullView a INNER JOIN
		Income.IncomePersonalView b ON a.ID_ID = b.ID_ID
	WHERE
		ID_CALC = 1 AND
		(IN_DATE >= @DT OR @DT IS NULL) AND
		(
			NOT EXISTS
			(
				SELECT *
				FROM
					Salary.PersonalSalary INNER JOIN
					Salary.PersonalSalaryDetail ON PSD_ID_MASTER = PS_ID
				WHERE PSD_ID_INCOME = a.ID_ID
			)
			/*
			OR
			(
				(
					SELECT SUM(IP_PERCENT)
					FROM Income.IncomePersonal z
					WHERE z.IP_ID_INCOME = a.ID_ID
				) >= 100
				AND EXISTS
					(
						SELECT *
						FROM
							Salary.PersonalSalary INNER JOIN
							Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
						WHERE PS_ID_PERSONAL = b.PER_ID_MASTER AND PSD_ID_INCOME = a.ID_ID AND PSD_SECOND = 0
					)
				AND NOT EXISTS
					(
						SELECT *
						FROM
							Salary.PersonalSalary INNER JOIN
							Salary.PersonalSalaryDetail ON PS_ID = PSD_ID_MASTER
						WHERE PS_ID_PERSONAL = b.PER_ID_MASTER AND PSD_ID_INCOME = a.ID_ID AND PSD_SECOND = 1
					)
			)*/
		)
		AND PER_ID_TYPE = @PT_ID
		AND ISNULL(ID_REPAY, 0) = 0
		--AND PER_ID_DEP = @DEP_ID
		--AND IN_DATE BETWEEN @BEGIN AND @END
	ORDER BY PER_NAME, CL_NAME, SYS_ORDER
END
GO
GRANT EXECUTE ON [Salary].[SALARY_UNCALC_SELECT] TO rl_salary_w;
GO
