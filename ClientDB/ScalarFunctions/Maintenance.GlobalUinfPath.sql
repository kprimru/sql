USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Maintenance].[GlobalUinfPath]
()
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @RES VARCHAR(500)

	SELECT @RES = GS_VALUE
	FROM Maintenance.GlobalSettings
	WHERE GS_NAME = 'UINF_PATH'
		
	RETURN @RES
END
