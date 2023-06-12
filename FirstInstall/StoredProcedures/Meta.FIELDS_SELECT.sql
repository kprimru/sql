﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Meta].[FIELDS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Meta].[FIELDS_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Meta].[FIELDS_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT FL_ID, FL_NAME, FL_CAPTION, FL_WIDTH, FL_VISIBLE, FL_SYSTEM
	FROM Meta.Fields
END
GO
GRANT EXECUTE ON [Meta].[FIELDS_SELECT] TO public;
GO
