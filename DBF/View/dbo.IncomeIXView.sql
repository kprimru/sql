﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[IncomeIXView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[IncomeIXView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[IncomeIXView]
WITH SCHEMABINDING
AS
	SELECT IN_ID_CLIENT, ID_ID_PERIOD, ID_ID_DISTR, SUM(ID_PRICE) AS ID_PRICE, COUNT_BIG(*) AS ID_CNT
	FROM
		dbo.IncomeDistrTable INNER JOIN
        dbo.IncomeTable	ON ID_ID_INCOME = IN_ID
	GROUP BY IN_ID_CLIENT, ID_ID_PERIOD, ID_ID_DISTR
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.IncomeIXView(IN_ID_CLIENT,ID_ID_DISTR,ID_ID_PERIOD)] ON [dbo].[IncomeIXView] ([IN_ID_CLIENT] ASC, [ID_ID_DISTR] ASC, [ID_ID_PERIOD] ASC);
GO
