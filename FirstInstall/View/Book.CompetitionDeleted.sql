USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Book].[CompetitionDeleted]
--WITH SCHEMABINDING
AS
	SELECT
		CP_ID_MASTER, CP_ID,
		HLF_ID, HLF_ID_MASTER, HLF_NAME,
		CP_NAME, CP_COUNT, CP_BONUS,
		CP_DATE, CP_END
	FROM
		Book.CompetitionAll a
	WHERE CP_REF = 3