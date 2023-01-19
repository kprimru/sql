﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[DepartmentDeleted]', 'V ') IS NULL EXEC('CREATE VIEW [Personal].[DepartmentDeleted]  AS SELECT 1')
GO
ALTER VIEW [Personal].[DepartmentDeleted]
--WITH SCHEMABINDING
AS
	SELECT
		DP_ID_MASTER, DP_ID, DP_NAME,
		DP_FULL, DP_DATE, DP_END
	FROM
		Personal.DepartmentAll a
	WHERE DP_REF = 3GO
