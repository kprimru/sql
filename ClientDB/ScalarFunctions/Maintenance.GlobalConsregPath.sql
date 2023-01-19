﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalConsregPath]', 'FN') IS NULL EXEC('CREATE FUNCTION [Maintenance].[GlobalConsregPath] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Maintenance].[GlobalConsregPath]
()
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @RES VARCHAR(500)

	SELECT @RES = GS_VALUE
	FROM Maintenance.GlobalSettings
	WHERE GS_NAME = 'CONSREG_PATH'

	RETURN @RES
END
GO
