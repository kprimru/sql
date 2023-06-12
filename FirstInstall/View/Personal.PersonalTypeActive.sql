USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PersonalTypeActive]', 'V ') IS NULL EXEC('CREATE VIEW [Personal].[PersonalTypeActive]  AS SELECT 1')
GO
ALTER VIEW [Personal].[PersonalTypeActive]
--WITH SCHEMABINDING
AS
	SELECT
		PT_ID_MASTER, PT_ID, PT_NAME,
		PT_ALIAS, PT_DATE, PT_END
	FROM
		Personal.PersonalTypeAll
	WHERE PT_REF = 1GO
