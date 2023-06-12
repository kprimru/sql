﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Install].[InstallCommentsFullView]', 'V ') IS NULL EXEC('CREATE VIEW [Install].[InstallCommentsFullView]  AS SELECT 1')
GO
ALTER VIEW [Install].[InstallCommentsFullView]
--WITH SCHEMABINDING
AS
	SELECT
		INS_DATE, CL_NAME, VD_NAME,
		a.SYS_SHORT, a.DT_NAME, a.NT_NAME, a.TT_NAME, DH_STR,
		IC_DATE, IC_USER, IC_TEXT
	FROM
		Install.InstallCommentsView a LEFT OUTER JOIN
		Distr.DistrLast ON DH_ID = IND_ID_DISTRGO
