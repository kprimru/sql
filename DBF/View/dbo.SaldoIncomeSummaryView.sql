﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SaldoIncomeSummaryView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[SaldoIncomeSummaryView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[SaldoIncomeSummaryView]
AS
	SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, SL_DATE, ID_PRICE, PR_DATE, SL_REST
	FROM
		dbo.SaldoTable INNER JOIN
	    dbo.ClientTable ON CL_ID = SL_ID_CLIENT INNER JOIN
    	dbo.DistrView WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR INNER JOIN
	    dbo.IncomeDistrTable ON ID_ID = SL_ID_IN_DIS INNER JOIN
    	dbo.PeriodTable ON PR_ID = ID_ID_PERIOD
GO
