USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BillAllRestView]
AS
	SELECT 
		SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE,
		(
			BD_TOTAL_PRICE - 
				ISNULL(
					(
						SELECT SUM(ID_PRICE) 
						FROM dbo.IncomeAllIXView b WITH(NOEXPAND)							
						WHERE a.SYS_REG_NAME = b.SYS_REG_NAME
							AND a.DIS_NUM = b.DIS_NUM
							AND a.DIS_COMP_NUM = b.DIS_COMP_NUM
							AND a.PR_DATE = b.PR_DATE
					), 0)
		) AS BD_REST
	FROM 
		dbo.BillAllIXView a WITH(NOEXPAND)
