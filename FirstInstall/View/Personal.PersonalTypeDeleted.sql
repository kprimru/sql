USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PersonalTypeDeleted]', 'V ') IS NULL EXEC('CREATE VIEW [Personal].[PersonalTypeDeleted]  AS SELECT 1')
GO
ALTER VIEW [Personal].[PersonalTypeDeleted]
--WITH SCHEMABINDING
AS
	SELECT
		PT_ID_MASTER, PT_ID, PT_NAME,
		PT_ALIAS, PT_DATE, PT_END
	FROM
		Personal.PersonalTypeAll a
	WHERE PT_REF = 3GO
