﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Book].[CompetitionLast]', 'V ') IS NULL EXEC('CREATE VIEW [Book].[CompetitionLast]  AS SELECT 1')
GO
ALTER VIEW [Book].[CompetitionLast]
--WITH SCHEMABINDING
AS
	SELECT
		CP_ID_MASTER, CP_ID,
		HLF_ID, HLF_ID_MASTER, HLF_NAME,
		CP_NAME, CP_COUNT, CP_BONUS,
		CP_DATE, CP_END
	FROM
		Book.CompetitionAll a
	WHERE CP_REF IN (1, 3)GO
