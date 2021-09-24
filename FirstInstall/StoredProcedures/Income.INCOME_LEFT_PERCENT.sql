USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Income].[INCOME_LEFT_PERCENT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		ID_ID, IN_DATE, CL_NAME, VD_NAME, SYS_SHORT, SYS_ORDER, DT_NAME, NT_NAME, TT_NAME, ID_COUNT, ID_MON_CNT, ID_COMMENT,
		ID_MAX_PERCENT, ID_PERCENT, ID_PERSONAL, IP_PERCENT, IP_ID,
		CASE
			WHEN ID_PERCENT > ID_MAX_PERCENT THEN '��������! ������� ������� ������ ������������ ������!'
			ELSE '������� ������� ������ ������������ ������'
		END AS ID_PER_COMMENT

	FROM
		(
			SELECT
				ID_ID, IN_DATE, CL_NAME, VD_NAME,
				SYS_SHORT, SYS_ORDER, DT_NAME, NT_NAME, TT_NAME,
				ID_COUNT, ID_MAX_PERCENT, ID_COMMENT, ID_MON_CNT, ID_PERSONAL,
				IP_PERCENT, IP_ID,
					(
						SELECT SUM(IP_PERCENT)
						FROM Income.IncomePersonal
						WHERE IP_ID_INCOME = ID_ID
					) AS ID_PERCENT
			FROM Income.IncomeFullView INNER JOIN
				Income.IncomePersonal ON IP_ID_INCOME = ID_ID
		) AS o_O
	WHERE ID_PERCENT <> ID_MAX_PERCENT
	ORDER BY IN_DATE DESC, CL_NAME, SYS_ORDER
END
GO
GRANT EXECUTE ON [Income].[INCOME_LEFT_PERCENT] TO rl_income_r;
GO
