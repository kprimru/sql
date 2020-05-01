USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[ActView]
AS
SELECT
		ACT_ID, ACT_ID_CLIENT, ACT_DATE, ACT_ID_INVOICE, ACT_SIGN, -- PR_DATE, PR_ID,
			(
				SELECT SUM(AD_TOTAL_PRICE)
				FROM dbo.ActDistrTable
				WHERE AD_ID_ACT = a.ACT_ID
			) AS ACT_PRICE, ACT_PRINT, ORG_ID, ORG_PSEDO, COUR_ID, COUR_NAME, ACT_ID_PAYER
	FROM
		dbo.ActTable AS a INNER JOIN
		dbo.OrganizationTable ON ORG_ID = ACT_ID_ORG LEFT OUTER JOIN
		dbo.CourierTable ON COUR_ID = ACT_ID_COUR
		-- INNER JOIN dbo.PeriodTable AS b ON ACT_ID_PERIOD = PR_ID
