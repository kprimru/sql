﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[DepartmentAll]', 'V ') IS NULL EXEC('CREATE VIEW [Personal].[DepartmentAll]  AS SELECT 1')
GO
ALTER VIEW [Personal].[DepartmentAll]
--WITH SCHEMABINDING
AS
	SELECT
		DP_ID_MASTER, DP_ID, DP_NAME,
		DP_FULL, DP_DATE, DP_END, DP_REF
	FROM
		Personal.DepartmentDetailGO
