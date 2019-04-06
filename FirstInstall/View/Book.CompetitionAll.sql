USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Book].[CompetitionAll] 
--WITH SCHEMABINDING
AS
	SELECT 
		CP_ID_MASTER, CP_ID, 	
		HLF_ID, HLF_ID_MASTER, HLF_NAME,	
		CP_NAME, CP_COUNT, CP_BONUS,
		CP_DATE, CP_END, CP_REF
	FROM 
		Book.CompetitionDetail	INNER JOIN		
		Common.HalfLast			ON	HLF_ID_MASTER = CP_ID_HALF