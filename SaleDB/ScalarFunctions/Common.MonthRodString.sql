﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[MonthRodString]', 'FN') IS NULL EXEC('CREATE FUNCTION [Common].[MonthRodString] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Common].[MonthRodString]
(
	@DATE	SMALLDATETIME
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @RES VARCHAR(100)

	SELECT @RES = ROD
	FROM Common.MonthStr
	WHERE NUM = DATEPART(MONTH, @DATE)

	SELECT @RES = @RES + ' ' + CONVERT(VARCHAR(50), DATEPART(YEAR, @DATE))

	RETURN @RES
END
GO
