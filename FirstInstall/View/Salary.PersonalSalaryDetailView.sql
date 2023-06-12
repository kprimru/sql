﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[PersonalSalaryDetailView]', 'V ') IS NULL EXEC('CREATE VIEW [Salary].[PersonalSalaryDetailView]  AS SELECT 1')
GO
ALTER VIEW [Salary].[PersonalSalaryDetailView]
--WITH SCHEMABINDING
AS
	SELECT
		PSD_ID,
		PS_ID,
		b.CL_NAME, b.VD_NAME, b.SYS_SHORT, b.NT_NEW_NAME, b.DT_NAME, b.IN_DATE,
		b.ID_COMMENT, b.ID_FULL_DATE,
		a.ID_ID,
		PSD_SUM, PSD_PERCENT, PSD_MON, PSD_TOTAL, PSD_SECOND
	FROM
		Salary.PersonalSalaryDetail INNER JOIN
		Salary.PersonalSalary ON PS_ID = PSD_ID_MASTER INNER JOIN
		Income.IncomeDetail a ON ID_ID = PSD_ID_INCOME INNER JOIN
		Income.IncomeFullView b ON a.ID_ID = b.ID_ID
	GO
