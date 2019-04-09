USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Maintenance].[GlobalClientPhosicalDelete]
()
RETURNS BIT
AS
BEGIN
	DECLARE @RES BIT

	DECLARE @TMP VARCHAR(500)

	SELECT @TMP = GS_VALUE
	FROM Maintenance.GlobalSettings
	WHERE GS_NAME = 'CLIENT_PHISICAL_DELETE'

	IF @TMP = '1'
		SET @RES = CAST(1 AS BIT)
	ELSE
		SET @RES = CAST(0 AS BIT)
		
	RETURN @RES
END
