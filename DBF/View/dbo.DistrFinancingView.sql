USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DistrFinancingView]
AS
	SELECT 
		DF_ID, SN_NAME, SN_ID, SN_COEF, SN_ROUND, PP_ID, PP_NAME, PT_ID, PT_NAME, 
		PP_COEF_MUL, PP_COEF_ADD, DIS_STR, DIS_ID, CD_ID_CLIENT, DF_FIXED_PRICE, 
		DF_DISCOUNT, DF_COEF, CD_ID, a.SYS_ID, a.SYS_ID_SO, PR_ID, PR_DATE, 
		DSS_REPORT, DSS_NAME, DF_MON_COUNT,	DF_ID_PERIOD, a.SYS_ORDER, b.SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM,
		SST_CAPTION, SST_ID,
		DIS_ACTIVE, DF_ID_PRICE, DF_END, DF_BEGIN,
		CASE (
			SELECT COUNT(DISTINCT SYS_ID)
			FROM 
				dbo.PeriodRegTable c
				INNER JOIN dbo.SystemTable d ON c.REG_ID_SYSTEM = d.SYS_ID
			WHERE DIS_NUM = REG_DISTR_NUM 
				AND DIS_COMP_NUM = REG_COMP_NUM 
				AND d.SYS_ID_HOST = b.SYS_ID_HOST
		) WHEN 0 THEN '���' WHEN 1 THEN '���' ELSE '��' END AS DF_EXCHANGE
	FROM        
		dbo.ClientDistrView a
		LEFT OUTER JOIN dbo.SystemTable b ON a.SYS_ID = b.SYS_ID
		LEFT OUTER JOIN dbo.DistrFinancingTable ON DIS_ID = DF_ID_DISTR 
		LEFT OUTER JOIN dbo.SystemNetTable ON DF_ID_NET = SN_ID 
		LEFT OUTER JOIN	dbo.PriceTable ON DF_ID_PRICE = PP_ID 
		LEFT OUTER JOIN dbo.PriceTypeTable ON PP_ID_TYPE = PT_ID 
		LEFT OUTER JOIN dbo.PeriodTable ON PR_ID = DF_ID_PERIOD 
		LEFT OUTER JOIN dbo.SystemTypeTable ON SST_ID = DF_ID_TYPE 		
