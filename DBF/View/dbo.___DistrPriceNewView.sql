USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DistrPriceNewView]
--WITH SCHEMABINDING
AS
	SELECT
		CD_ID_CLIENT,
		SYS_SHORT_NAME + ' ' +
			CONVERT(VARCHAR(20), DIS_NUM) +
			CASE DIS_COMP_NUM
				WHEN 1 THEN ''
				ELSE '/' + CONVERT(VARCHAR(20), DIS_COMP_NUM)
			END DIS_STR,
		PR_DATE, PP_NAME, SN_NAME,
		(
			CASE DF_FIXED_PRICE
				WHEN 0 THEN
					CASE SN_NAME
						WHEN '����' THEN
							CAST(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE * SNCC_VALUE, -1) * TTP_COEF, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						ELSE
							CAST(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE * SNCC_VALUE, 2) * TTP_COEF, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
					END
				ELSE CAST(ROUND(DF_FIXED_PRICE, 2) AS MONEY)
			END
		) AS DIS_PRICE,
		DIS_ID, PR_ID, SN_ID, SYS_ID_SO, DSS_REPORT, DF_MON_COUNT, DF_ID_PERIOD, SYS_ORDER
	FROM 
		dbo.DistrFinancingTable
		INNER JOIN dbo.ClientDistrTable ON CD_ID_DISTR = DF_ID_DISTR
		INNER JOIN dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
		INNER JOIN dbo.DistrTable ON DIS_ID = CD_ID_DISTR
		INNER JOIN dbo.SystemTable ON SYS_ID = DIS_ID_SYSTEM
		INNER JOIN dbo.PriceTable ON PP_ID = DF_ID_PRICE
		INNER JOIN dbo.PriceTypeTable ON PP_ID_TYPE = PT_ID
		INNER JOIN dbo.PriceSystemTable ON PS_ID_SYSTEM = SYS_ID AND PS_ID_TYPE = PT_ID
		INNER JOIN dbo.SystemNetTable ON SN_ID = DF_ID_NET
		INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID AND SNCC_ID_PERIOD = PS_ID_PERIOD
		INNER JOIN dbo.TechnolTypeTable ON TT_ID = DF_ID_TECH_TYPE
		INNER JOIN dbo.TechnolTypePeriod ON TTP_ID_TECH = TT_ID AND TTP_ID_PERIOD = PS_ID_PERIOD
		INNER JOIN dbo.PeriodTable ON PR_ID = PS_ID_PERIODGO
