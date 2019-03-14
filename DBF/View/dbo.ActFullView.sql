USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
CREATE VIEW [dbo].[ActFullView]
AS
SELECT 
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CO_NUM, CO_DATE, PR_DATE, PR_ID, PR_END_DATE, DATENAME(MM, PR_DATE) AS PR_MONTH, DATENAME(YY, PR_DATE) AS PR_YEAR,
		SYS_NAME, DIS_ID, DIS_NUM, CO_ID, PER_FAM, PER_NAME, PER_OTCH, POS_NAME,
		ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME, ORG_PHONE, 
		ISNULL(ORGC_ACCOUNT, ORG_ACCOUNT) AS ORG_ACCOUNT, BA_LORO AS ORG_LORO, BA_BIK AS ORG_BIK, ORG_INN, ORG_KPP, ORG_OKONH, ORG_OKPO,
		ORG_BUH_FAM, ORG_BUH_NAME, ORG_BUH_OTCH,
		(ORG_BUH_FAM + ' ' + LEFT(ORG_BUH_NAME, 1) + '.' + LEFT(ORG_BUH_OTCH, 1) + '.') AS ORG_BUH_SHORT,
		(ORG_DIR_FAM + ' ' + LEFT(ORG_DIR_NAME, 1) + '.' + LEFT(ORG_DIR_OTCH, 1) + '.') AS ORG_DIR_SHORT,
		ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH,
		BA_NAME,
		CT_NAME, CT_PREFIX, SYS_ID_SO, SYS_ORDER,
		AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE, TX_PERCENT, TX_NAME, SO_ID, SO_BILL_STR, SO_INV_UNIT,
		ACT_ID, AD_ID_PERIOD, ACT_ID_CLIENT, ACT_ID_INVOICE
	FROM 
		dbo.ActDistrTable INNER JOIN
		dbo.ActTable ON AD_ID_ACT = ACT_ID INNER JOIN
		dbo.ClientTable ON CL_ID = ACT_ID_CLIENT INNER JOIN
		dbo.DistrView ON DIS_ID = AD_ID_DISTR INNER JOIN
		dbo.PeriodTable ON PR_ID = AD_ID_PERIOD LEFT OUTER JOIN
		dbo.OrganizationTable ON ORG_ID = CL_ID_ORG LEFT OUTER JOIN		
		dbo.OrganizationCalc ON ORGC_ID = CL_ID_ORG_CALC LEFT OUTER JOIN		
		dbo.ContractDistrTable ON COD_ID_DISTR = AD_ID_DISTR LEFT OUTER JOIN
		dbo.ContractTable ON COD_ID_CONTRACT = CO_ID 
						AND CO_ID_CLIENT = CL_ID LEFT OUTER JOIN
		dbo.ClientPersonalTable ON CL_ID = PER_ID_CLIENT LEFT OUTER JOIN
		dbo.PositionTable ON POS_ID = PER_ID_POS LEFT OUTER JOIN
		dbo.ClientAddressTable ON CL_ID = CA_ID_CLIENT LEFT OUTER JOIN
		dbo.AddressView ON ST_ID = CA_ID_STREET LEFT OUTER JOIN
		dbo.SaleObjectTable ON SO_ID = SYS_ID_SO LEFT OUTER JOIN
		dbo.TaxTable ON TX_ID = SO_ID_TAX LEFT OUTER JOIN
		dbo.BankTable ON BA_ID = ISNULL(ORGC_ID_BANK, ORG_ID_BANK)
	WHERE CO_ACTIVE = 1 AND CA_ID_TYPE = 1
