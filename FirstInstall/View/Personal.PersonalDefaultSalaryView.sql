﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PersonalDefaultSalaryView]', 'V ') IS NULL EXEC('CREATE VIEW [Personal].[PersonalDefaultSalaryView]  AS SELECT 1')
GO

ALTER VIEW [Personal].[PersonalDefaultSalaryView]
--WITH SCHEMABINDING
AS
	SELECT
		PDS_ID, PER_ID_MASTER, PER_NAME, PDS_VALUE, PDS_COMMENT, PR_NAME
	FROM
		Personal.PersonalActive INNER JOIN
		Personal.PersonalDefaultSalary ON PDS_ID_PERSONAL = PER_ID_MASTER INNER JOIN
		Common.PeriodLast ON PR_ID_MASTER = PDS_ID_PERIOD
									GO
