﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ActDistrView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ActDistrView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ActDistrView]
AS
	SELECT
		ACT_ID, ACT_ID_CLIENT, AD_ID_PERIOD, PR_ID, PR_DATE,
		AD_ID, AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE, --AD_SIGN, AD_DATE,
		AD_EXPIRE, dbo.ActDistrTable.IsOnline,
		DIS_ID, DIS_STR,
		TX_ID, TX_NAME, TX_PERCENT, TX_CAPTION

	FROM
		dbo.ActTable INNER JOIN
        dbo.ActDistrTable ON ACT_ID = AD_ID_ACT INNER JOIN
        dbo.TaxTable ON AD_ID_TAX = TX_ID INNER JOIN
        dbo.DistrView WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR INNER JOIN
		dbo.PeriodTable ON PR_ID = AD_ID_PERIOD
GO
