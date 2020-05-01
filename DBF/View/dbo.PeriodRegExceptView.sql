USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[PeriodRegExceptView]
AS
	SELECT
		REG_ID,
		REG_ID_PERIOD,
		REG_ID_SYSTEM,
		REG_DISTR_NUM,
		REG_COMP_NUM,
		REG_ID_HOST,
		REG_ID_TYPE,
		REG_ID_NET,
		REG_ID_STATUS,
		REG_ID_COUR,
		REG_COMMENT,
		REG_MAIN,
		REG_COMPLECT
	FROM
		dbo.PeriodRegTable
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.PeriodRegExcept
			WHERE PRE_ID_PERIOD = REG_ID_PERIOD
				AND PRE_ID_SYSTEM = REG_ID_SYSTEM
				AND PRE_DISTR = REG_DISTR_NUM
				AND PRE_COMP = REG_COMP_NUM
		)

	UNION ALL

	SELECT
		REG_ID,
		PRE_ID_PERIOD,
		PRE_ID_SYSTEM,
		PRE_DISTR,
		PRE_COMP,
		PRE_ID_HOST,
		PRE_ID_TYPE,
		PRE_ID_NET,
		PRE_ID_STATUS,
		REG_ID_COUR,
		REG_COMMENT,
		REG_MAIN,
		REG_COMPLECT
	FROM
		dbo.PeriodRegExcept
		INNER JOIN dbo.PeriodRegTable ON PRE_ID_PERIOD = REG_ID_PERIOD
									AND PRE_ID_SYSTEM = REG_ID_SYSTEM
									AND PRE_DISTR = REG_DISTR_NUM
									AND PRE_COMP = REG_COMP_NUM
