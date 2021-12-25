﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Distr].[HostActive]
--WITH SCHEMABINDING
AS
	SELECT
		HST_ID_MASTER, HST_ID, HST_NAME,
		HST_REG, HST_DATE, HST_END
	FROM
		Distr.HostAll
	WHERE HST_REF = 1GO
