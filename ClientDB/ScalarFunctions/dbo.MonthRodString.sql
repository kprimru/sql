USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[MonthRodString]
(
	@DATE	SMALLDATETIME
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @RES VARCHAR(100)

	SET @RES = CONVERT(VARCHAR(50), DATEPART(DAY, @DATE)) + ' '
	
	SELECT @RES = @RES + ROD
	FROM dbo.Month
	WHERE NUM = DATEPART(MONTH, @DATE)
	
	SELECT @RES = @RES + ' ' + CONVERT(VARCHAR(50), DATEPART(YEAR, @DATE))

	RETURN @RES
END