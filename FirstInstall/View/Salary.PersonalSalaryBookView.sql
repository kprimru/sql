﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[PersonalSalaryBookView]', 'V ') IS NULL EXEC('CREATE VIEW [Salary].[PersonalSalaryBookView]  AS SELECT 1')
GO
ALTER VIEW [Salary].[PersonalSalaryBookView]
--WITH SCHEMABINDING
AS
	SELECT
		PSB_ID,
		PS_ID,
		IB_ID,
		PSB_SUM, PSB_PERCENT, PSB_COUNT, PSB_TOTAL,
		PSB_DELIVERY, PSB_PAYED
	FROM
		Salary.PersonalSalaryBook INNER JOIN
		Salary.PersonalSalary ON PS_ID = PSB_ID_MASTER INNER JOIN
		Income.IncomeBook ON IB_ID = PSB_ID_IB
	GO
