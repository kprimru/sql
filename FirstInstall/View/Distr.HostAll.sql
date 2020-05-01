USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Distr].[HostAll]
--WITH SCHEMABINDING
AS
	SELECT
		HST_ID_MASTER, HST_ID, HST_NAME,
		HST_REG, HST_DATE, HST_END, HST_REF
	FROM
		Distr.HostDetail