USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Salary].[BonusConditionAll] 
--WITH SCHEMABINDING
AS
	SELECT 
		BC_ID, BC_ID_MASTER, 
		BC_PREPAY, BC_MON_COUNT, BC_ACTION, BC_EXCHANGE,
		BC_DT_SUP_CON, BC_RESTORE_MAIN, BC_RESTORE_ADD, 
		BC_SUP_PRICE, BC_RES_PRICE, BC_PERCENT, 
		BC_ORDER, 
		BC_DATE, BC_END, BC_REF
	FROM 
		Salary.BonusConditionDetail