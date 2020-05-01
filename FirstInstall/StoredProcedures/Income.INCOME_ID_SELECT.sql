USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Income].[INCOME_ID_SELECT]
	@ID_ID	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		IN_ID, IN_DATE, IN_PAY,
		CL_ID_MASTER, CL_NAME,
		VD_ID_MASTER, VD_NAME,
		ID_ID, ID_COUNT, ID_DEL_SUM, ID_DEL_PRICE, ID_DEL_DISCOUNT,
		ID_ACTION, ID_RESTORE, ID_EXCHANGE, 
		ID_MON_CNT, ID_SUP_PRICE, ID_SUP_DISCOUNT,
		ID_SUP_MONTH, ID_PREPAY,
		SYS_ID_MASTER, SYS_SHORT,
		DT_ID_MASTER, DT_NAME,
		NT_ID_MASTER, NT_NAME,
		TT_ID_MASTER, TT_NAME
	FROM Income.IncomeFullView
	WHERE ID_ID IN
		(
			SELECT ID
			FROM Common.TableFromList(@ID_ID, ',')
		)
END
GRANT EXECUTE ON [Income].[INCOME_ID_SELECT] TO rl_income_r;
GO