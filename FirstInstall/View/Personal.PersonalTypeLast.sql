﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PersonalTypeLast]', 'V ') IS NULL EXEC('CREATE VIEW [Personal].[PersonalTypeLast]  AS SELECT 1')
GO

ALTER VIEW [Personal].[PersonalTypeLast]
--WITH SCHEMABINDING
AS
	SELECT
		PT_ID_MASTER, PT_ID, PT_NAME,
		PT_ALIAS, PT_DATE, PT_END
	FROM
		Personal.PersonalTypeAll a
	WHERE PT_REF IN (1, 3)
GO
