﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CheckWorkDateTime]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[CheckWorkDateTime] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE OR ALTER FUNCTION [dbo].[CheckWorkDateTime]
(
	@DT	DATETIME
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @RES	VARCHAR(100)

	SET @RES = ''

	DECLARE @T	DATETIME

	SET @T = CONVERT(DATETIME, CONVERT(VARCHAR(20), @DT, 112), 112)

	DECLARE @WORK BIT

	SELECT @WORK = CalendarWork
	FROM dbo.Calendar
	WHERE CalendarDate = @T

	IF @WORK = 0
		SET @RES = 'Выходной день'
	ELSE IF DATEPART(HOUR, @DT) < 9 OR DATEPART(HOUR, @DT) > 18
		SET @RES = 'Время до 9 или после 18'

	RETURN @RES
END
GO
