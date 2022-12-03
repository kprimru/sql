﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DistrPriceView]
AS
	SELECT
		CD_ID_CLIENT, DIS_STR, c.PR_DATE, PP_NAME, SN_NAME,
		(
			CASE DF_FIXED_PRICE
				WHEN 0 THEN
				Round(
					[dbo].[GlobalPriceCoef]() *
					CASE
						/*
						WHEN SN_NAME = 'ОВП' AND SYS_REG_NAME IN (
													'SKZO', 'SKZB',
															'SKBP', 'SKBO', 'SKBB',
													'SKJE', 'SKJP', 'SKJO', 'SKJB',
													'SKUE', 'SKUP', 'SKUO', 'SKUB',
													'SBOE', 'SBOP', 'SBOO', 'SBOB') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1.1, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						*/
						WHEN SN_NAME = 'ОВП' AND SYS_REG_NAME IN ('SKBEM', 'SBOEM', 'SKJEM', 'SKUEM') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						WHEN SN_NAME = 'ОВМ1' AND SYS_REG_NAME IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1.25, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						WHEN SN_NAME = 'ОВМ2' AND SYS_REG_NAME IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1.5, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						WHEN SN_NAME = 'ОВМ3' AND SYS_REG_NAME IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 2.0, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						WHEN SN_NAME = 'ОВМ5' AND SYS_REG_NAME IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 3.0, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						WHEN SN_NAME = 'ОВМ-Ф (1;2)' AND SYS_REG_NAME IN ('SKBO', 'SKUO', 'SBOO', 'SKJP', 'SKZO', 'SKZB') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1.3, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						WHEN SN_NAME = 'ОВМ-Ф (1;2)' AND SYS_REG_NAME IN ('SKUP', 'SBOP') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1.5, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						WHEN SN_NAME = 'ОВС5' AND SYS_REG_NAME IN ('SKUP', 'SBOP') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 2.3, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						WHEN SN_NAME = 'ОВС10' AND SYS_REG_NAME IN ('SKUP', 'SBOP') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 2.52, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						WHEN SN_NAME = 'ОВС20' AND SYS_REG_NAME IN ('SKUP', 'SBOP') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 2.64, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						WHEN SN_NAME = 'ОВС50' AND SYS_REG_NAME IN ('SKUP', 'SBOP') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 2.86, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
						ELSE CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * SNCC_VALUE, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY)
					END
				, 2)
				ELSE CAST(ROUND(DF_FIXED_PRICE, 2) AS MONEY)
			END
		) AS DIS_PRICE,
		--CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * SNCC_VALUE, SNCC_ROUND) * 1, 2) * DF_COEF, 2) * (100 - DF_DISCOUNT), 2) / 100, 2) AS MONEY) AS DIS_ORIGIN,
		Round(
			[dbo].[GlobalPriceCoef]() *
			CASE
				WHEN SN_NAME = 'ОВП' AND SYS_REG_NAME IN ('SKBEM', 'SBOEM', 'SKJEM', 'SKUEM') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				WHEN SN_NAME = 'ОВМ1' AND SYS_REG_NAME IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1.25, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				WHEN SN_NAME = 'ОВМ2' AND SYS_REG_NAME IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1.5, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				WHEN SN_NAME = 'ОВМ3' AND SYS_REG_NAME IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 2.0, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				WHEN SN_NAME = 'ОВМ5' AND SYS_REG_NAME IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 3.0, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				WHEN SN_NAME = 'ОВМ-Ф (1;2)' AND SYS_REG_NAME IN ('SKBO', 'SKUO', 'SBOO', 'SKJP', 'SKZO', 'SKZB') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1.3, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				WHEN SN_NAME = 'ОВМ-Ф (1;2)' AND SYS_REG_NAME IN ('SKUP', 'SBOP') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 1.5, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				WHEN SN_NAME = 'ОВС5' AND SYS_REG_NAME IN ('SKUP', 'SBOP') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 2.3, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				WHEN SN_NAME = 'ОВС10' AND SYS_REG_NAME IN ('SKUP', 'SBOP') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 2.52, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				WHEN SN_NAME = 'ОВС20' AND SYS_REG_NAME IN ('SKUP', 'SBOP') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 2.64, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				WHEN SN_NAME = 'ОВС50' AND SYS_REG_NAME IN ('SKUP', 'SBOP') THEN CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * 2.86, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
				ELSE CAST(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(PS_PRICE + PP_COEF_ADD, 2) * PP_COEF_MUL, 2) * SNCC_VALUE, SNCC_ROUND) * 1, 2) * DF_COEF, 2), 2), 2) AS MONEY)
			END
		, 2)AS DIS_ORIGIN,
		DIS_ID, c.PR_ID, SN_ID, SYS_ID_SO, DSS_REPORT, DF_MON_COUNT,
		DF_ID_PERIOD, SYS_ORDER, DF_END
	FROM
		dbo.DistrFinancingView AS a
		LEFT OUTER JOIN dbo.PriceSystemTable AS b ON b.PS_ID_SYSTEM = a.SYS_ID
		LEFT OUTER JOIN dbo.PeriodTable AS c ON c.PR_ID = b.PS_ID_PERIOD
		LEFT OUTER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID AND SNCC_ID_PERIOD = c.PR_ID
	WHERE DF_ID_PRICE = PP_ID
		AND PS_ID_TYPE = PT_ID

GO
