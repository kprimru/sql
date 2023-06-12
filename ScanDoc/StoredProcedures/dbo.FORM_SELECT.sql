﻿USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FORM_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FORM_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[FORM_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 2 AS TP, ID, NAME
	FROM dbo.Form

	UNION ALL

	SELECT 1 AS TP, NULL, '[нет]'
END
GO
GRANT EXECUTE ON [dbo].[FORM_SELECT] TO rl_user;
GO
