﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PersonalTypeAll]', 'V ') IS NULL EXEC('CREATE VIEW [Personal].[PersonalTypeAll]  AS SELECT 1')
GO
ALTER VIEW [Personal].[PersonalTypeAll]
--WITH SCHEMABINDING
AS
	SELECT
		PT_ID_MASTER, PT_ID, PT_NAME,
		PT_ALIAS, PT_DATE, PT_END, PT_REF
	FROM
		Personal.PersonalTypeDetailGO
