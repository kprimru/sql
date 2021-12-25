﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalServiceReportPath]', 'FN') IS NULL EXEC('CREATE FUNCTION [Maintenance].[GlobalServiceReportPath] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [Maintenance].[GlobalServiceReportPath]
()
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @RES VARCHAR(500)

	SELECT @RES = GS_VALUE
	FROM Maintenance.GlobalSettings
	WHERE GS_NAME = 'SERVICE_REPORT_PATH'

	RETURN @RES
END
GO
