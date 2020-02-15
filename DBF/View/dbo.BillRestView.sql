USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BillRestView]
AS
SELECT 
		BD_ID, BL_ID_CLIENT, BL_ID_PERIOD, BD_ID_DISTR, BD_TOTAL_PRICE,
		(
			BD_TOTAL_PRICE - 
				ISNULL(
					(
						SELECT SUM(ID_PRICE) 
						FROM 
							/*
							dbo.IncomeDistrTable INNER JOIN 
							dbo.IncomeTable ON ID_ID_INCOME = IN_ID LEFT OUTER JOIN
							*/
							dbo.IncomeIXView WITH(NOEXPAND) INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR INNER JOIN
							dbo.SaleObjectTable a ON SO_ID = SYS_ID_SO
						WHERE IN_ID_CLIENT = BL_ID_CLIENT 
							AND ID_ID_DISTR = BD_ID_DISTR
							AND ID_ID_PERIOD = BL_ID_PERIOD
							AND a.SO_ID = b.SO_ID
					), 0)
		) AS BD_REST, SO_NAME
	FROM 
		dbo.BillTable INNER JOIN
		dbo.BillDistrTable ON BL_ID = BD_ID_BILL LEFT OUTER JOIN
		dbo.DistrView WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR INNER JOIN
		dbo.SaleObjectTable b ON SO_ID = SYS_ID_SO
