﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Distr].[HostLast]', 'V ') IS NULL EXEC('CREATE VIEW [Distr].[HostLast]  AS SELECT 1')
GO

ALTER VIEW [Distr].[HostLast]
--WITH SCHEMABINDING
AS
	SELECT
		HST_ID_MASTER, HST_ID, HST_NAME,
		HST_REG, HST_DATE, HST_END
	FROM
		Distr.HostAll a
	WHERE HST_REF IN (1, 3)
GO
