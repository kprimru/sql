﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[SaldoDetailView]
AS
SELECT
	SL_ID, SL_DATE, SL_TP,
	CL_FULL_NAME, CL_ID,
	DIS_STR, DIS_ID,
	bp.PR_ID AS BPR_ID, bp.PR_DATE AS BPR_DATE,	BD_TOTAL_PRICE,
	ip.PR_ID AS IPR_ID, ip.PR_DATE AS IPR_DATE, ID_PRICE,
	ap.PR_ID AS APR_ID, ap.PR_DATE AS APR_DATE, AD_TOTAL_PRICE,
	cp.PR_ID AS CPR_ID, cp.PR_DATE AS CPR_DATE, CSD_TOTAL_PRICE,
	SL_REST, SL_BEZ_NDS, BL_ID_PERIOD, AD_ID_PERIOD, CSD_ID_PERIOD,
	IN_ID, IN_DATE, IN_PAY_NUM, AD_ID, BD_ID, ID_ID, CSD_ID
FROM
	dbo.SaldoTable a INNER JOIN
	dbo.ClientTable b ON a.SL_ID_CLIENT = b.CL_ID INNER JOIN
	dbo.DistrView c WITH(NOEXPAND) ON a.SL_ID_DISTR = c.DIS_ID LEFT OUTER JOIN
	dbo.BillDistrTable d ON d.BD_ID = a.SL_ID_BILL_DIS LEFT OUTER JOIN
	dbo.BillTable e ON e.BL_ID = d.BD_ID_BILL LEFT OUTER JOIN
	dbo.IncomeDistrTable f ON f.ID_ID = a.SL_ID_IN_DIS LEFT OUTER JOIN
	dbo.IncomeTable g ON g.IN_ID = f.ID_ID_INCOME LEFT OUTER JOIN
	dbo.ActDistrTable h ON h.AD_ID = a.SL_ID_ACT_DIS LEFT OUTER JOIN
	dbo.ActTable i ON ACT_ID = h.AD_ID_ACT LEFT OUTER JOIN
	dbo.ConsignmentDetailTable j ON j.CSD_ID = SL_ID_CONSIG_DIS LEFT OUTER JOIN
	dbo.ConsignmentTable k ON k.CSG_ID = CSD_ID_CONS LEFT OUTER JOIN
	dbo.PeriodTable bp ON bp.PR_ID = e.BL_ID_PERIOD LEFT OUTER JOIN
	dbo.PeriodTable ap ON ap.PR_ID = h.AD_ID_PERIOD LEFT OUTER JOIN
	dbo.PeriodTable ip ON ip.PR_ID = f.ID_ID_PERIOD LEFT OUTER JOIN
	dbo.PeriodTable cp ON cp.PR_ID = j.CSD_ID_PERIOD
GO
