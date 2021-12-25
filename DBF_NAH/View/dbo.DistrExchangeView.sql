﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DistrExchangeView]
AS
	SELECT b.SYS_ID_HOST, a.REG_DISTR_NUM, a.REG_COMP_NUM, COUNT_BIG(*) AS CNT
	FROM
		dbo.PeriodRegTable a
		INNER JOIN dbo.SystemTable b ON b.SYS_ID = a.REG_ID_SYSTEM
		INNER JOIN dbo.PeriodRegTable c ON c.REG_DISTR_NUM = a.REG_DISTR_NUM AND c.REG_COMP_NUM = a.REG_COMP_NUM
		INNER JOIN dbo.SystemTable d ON d.SYS_ID = c.REG_ID_SYSTEM
	WHERE a.REG_ID_PERIOD <> c.REG_ID_PERIOD AND d.SYS_ID_HOST = b.SYS_ID_HOST AND d.SYS_ID <> b.SYS_ID
	GROUP BY b.SYS_ID_HOST, a.REG_DISTR_NUM, a.REG_COMP_NUMGO
