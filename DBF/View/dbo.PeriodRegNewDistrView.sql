﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PeriodRegNewDistrView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[PeriodRegNewDistrView]  AS SELECT 1')
GO

ALTER VIEW [dbo].[PeriodRegNewDistrView]
AS
	SELECT
		b.PR_ID AS REG_ID_PERIOD,
		SYS_ID_HOST,
		REG_DISTR_NUM,
		REG_COMP_NUM
	FROM
	(
		SELECT
			MIN(PR_DATE) AS PR_DATE,
			SYS_ID_HOST,
			REG_DISTR_NUM,
			REG_COMP_NUM
		FROM dbo.PeriodRegTable a
		INNER JOIN dbo.PeriodTable b ON a.REG_ID_PERIOD = b.PR_ID
		INNER JOIN dbo.SystemTable c ON a.REG_ID_SYSTEM = c.SYS_ID
		WHERE REG_ID_STATUS = 1
		GROUP BY
			SYS_ID_HOST,
			REG_DISTR_NUM,
			REG_COMP_NUM
	) AS a
	INNER JOIN dbo.PeriodTable b ON a.PR_DATE = b.PR_DATEGO
