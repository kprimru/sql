USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Common].[HalfActive]
--WITH SCHEMABINDING
AS
	SELECT
		HLF_ID_MASTER, HLF_ID, HLF_NAME,
		HLF_BEGIN_DATE, HLF_END_DATE,
		HLF_DATE, HLF_END
	FROM
		Common.HalfAll
	WHERE HLF_REF = 1