USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[INCOME_REPORT]	
	@DEP_ID	UNIQUEIDENTIFIER,
	@PR_ID	UNIQUEIDENTIFIER,
	@START	SMALLDATETIME,
	@END	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		PER_NAME, IN_DATE, CL_NAME, 
		SYS_SHORT, DT_NAME, NT_NAME, TT_NAME,
		ID_COMMENT, ID_COUNT, ID_MON_CNT, IP_PERCENT, PS_SALARY, PSD_TOTAL,
		SL_REASON
	FROM
		(
			SELECT 
				PER_NAME, IN_DATE, CL_NAME, SYS_ORDER,
				a.SYS_SHORT, DT_NAME, NT_NAME, TT_NAME,
				ID_COMMENT, ID_COUNT, ID_MON_CNT, IP_PERCENT, NULL AS PS_SALARY, NULL AS PSD_TOTAL, PER_ID_DEP,
				CASE
					WHEN ID_FULL_DATE IS NULL THEN '��� ������ ������'
					WHEN NOT EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INCOME = a.ID_ID
								AND IND_INSTALL_DATE IS NOT NULL
						) THEN '�� ����������� ���������'
					WHEN NOT EXISTS
						(
							SELECT *
							FROM Install.InstallDetail
							WHERE IND_ID_INCOME = a.ID_ID
								AND IND_ACT_RETURN IS NOT NULL
						) THEN '�� ��������� ����'
					ELSE '����������� �������'
				END AS SL_REASON
			FROM
				Income.IncomeFullView a INNER JOIN
				Income.IncomePersonalView b ON a.ID_ID = b.ID_ID
			WHERE
				NOT EXISTS
					(
						SELECT *
						FROM 
							Salary.PersonalSalary LEFT OUTER JOIN
							Salary.PersonalSalaryDetail ON PSD_ID_MASTER = PS_ID
						WHERE PSD_ID_INCOME = a.ID_ID
					)
	
			UNION ALL

			SELECT
				PER_NAME, IN_DATE, CL_NAME, SYS_ORDER,
				SYS_SHORT, DT_NAME, NT_NAME, TT_NAME, ID_COMMENT,
				PSD_COUNT, PSD_MON, PSD_PERCENT, PS_SALARY, PSD_TOTAL, PER_ID_DEP, '' --PSD_SUM, PSD_PRICE, 		
			FROM
				Salary.PersonalSalary	LEFT OUTER JOIN
				Salary.PersonalSalaryDetail ON PSD_ID_MASTER = PS_ID INNER JOIN
				Personal.PersonalLast ON PER_ID_MASTER	=	PS_ID_PERSONAL	LEFT OUTER JOIN		
				Income.IncomeFullView	ON ID_ID = PSD_ID_INCOME
			WHERE IN_DATE BETWEEN @START AND @END
				AND PS_ID_PERIOD = @PR_ID
		) AS o_O
	WHERE IN_DATE BETWEEN @START AND @END
		AND PER_ID_DEP = @DEP_ID
	ORDER BY PER_NAME, CL_NAME, SYS_ORDER
END
