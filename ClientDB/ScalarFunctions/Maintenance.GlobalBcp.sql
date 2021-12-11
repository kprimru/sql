USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalBcp]', 'FN') IS NULL EXEC('CREATE FUNCTION [Maintenance].[GlobalBcp] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [Maintenance].[GlobalBcp]
()
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @RES VARCHAR(500)

	SELECT @RES = GS_VALUE
	FROM Maintenance.GlobalSettings
	WHERE GS_NAME = 'BCP'

	RETURN @RES
END
GO
