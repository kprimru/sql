﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[DepartmentLast]', 'V ') IS NULL EXEC('CREATE VIEW [Personal].[DepartmentLast]  AS SELECT 1')
GO

ALTER VIEW [Personal].[DepartmentLast]
--WITH SCHEMABINDING
AS
	SELECT
		DP_ID_MASTER, DP_ID, DP_NAME,
		DP_FULL, DP_DATE, DP_END
	FROM
		Personal.DepartmentAll
	WHERE DP_REF IN (1, 3)GO
