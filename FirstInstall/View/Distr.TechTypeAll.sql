﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Distr].[TechTypeAll]
--WITH SCHEMABINDING
AS
	SELECT
		TT_ID_MASTER, TT_ID, TT_NAME, TT_SHORT,
		TT_REG, TT_COEF, TT_DATE, TT_END, TT_REF
	FROM
		Distr.TechTypeDetailGO
