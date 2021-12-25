﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Personal].[DepartmentActive]
--WITH SCHEMABINDING
AS
	SELECT
		DP_ID_MASTER, DP_ID, DP_NAME,
		DP_FULL, DP_DATE, DP_END
	FROM
		Personal.DepartmentAll
	WHERE DP_REF = 1GO
