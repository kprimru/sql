﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientView]  AS SELECT 1')
GO

ALTER VIEW [dbo].[ClientView]
AS
	SELECT
		a.CL_ID, a.CL_NUM, a.CL_PSEDO, a.CL_FULL_NAME, a.CL_SHORT_NAME, a.CL_FOUNDING, a.CL_EMAIL,
		a.CL_INN, a.CL_KPP, a.CL_OKPO, a.CL_OKONX, a.CL_ACCOUNT, a.CL_NOTE, a.CL_NOTE2, a.CL_PHONE,
		BA_ID, BA_NAME, AC_ID, AC_NAME, FIN_ID, FIN_NAME, SH_ID, SH_FULL_NAME,
		ORG_ID, ORG_SHORT_NAME, CLT_ID, CLT_NAME,
		b.CL_ID AS PAYER_ID, b.CL_PSEDO AS PAYER_PSEDO, a.CL_1C,
		ORGC_ID, ORGC_NAME
	FROM
		dbo.ClientTable a LEFT OUTER JOIN
        dbo.BankTable ON a.CL_ID_BANK = BA_ID LEFT OUTER JOIN
		dbo.ActivityTable ON a.CL_ID_ACTIVITY = AC_ID LEFT OUTER JOIN
		dbo.FinancingTable ON a.CL_ID_FIN = FIN_ID LEFT OUTER JOIN
		dbo.SubhostTable ON a.CL_ID_SUBHOST = SH_ID LEFT OUTER JOIN
		dbo.OrganizationTable ON a.CL_ID_ORG = ORG_ID LEFT OUTER JOIN
		dbo.ClientTypeTable ON CLT_ID = a.CL_ID_TYPE LEFT OUTER JOIN
		dbo.ClientTable b ON a.CL_ID_PAYER = b.CL_ID LEFT OUTER JOIN
		dbo.OrganizationCalc ON ORGC_ID = a.CL_ID_ORG_CALC
GO
