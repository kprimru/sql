﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Common].[PeriodActive]
--WITH SCHEMABINDING
AS
	SELECT
		PR_ID_MASTER, PR_ID, PR_NAME,
		PR_BEGIN_DATE, PR_END_DATE,
		PR_DATE, PR_END
	FROM
		Common.PeriodAll
	WHERE PR_REF = 1GO
