USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[OfficePersonalTestView]', 'V ') IS NULL EXEC('CREATE VIEW [Personal].[OfficePersonalTestView]  AS SELECT 1')
GO
ALTER VIEW [Personal].[OfficePersonalTestView]
AS
	SELECT SHORT, LOGIN
	FROM Personal.OfficePersonal
	WHERE END_DATE IS NULLGO
