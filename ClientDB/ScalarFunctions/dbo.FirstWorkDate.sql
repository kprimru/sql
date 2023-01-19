﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FirstWorkDate]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[FirstWorkDate] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[FirstWorkDate]
(
	@DATE	SMALLDATETIME
)
RETURNS SMALLDATETIME
AS
BEGIN
	DECLARE @RESULT	SMALLDATETIME

	SELECT TOP 1 @RESULT = CalendarDate
	FROM
		dbo.Calendar
	WHERE CalendarDate >= @DATE
		AND CalendarWork = 1
	ORDER BY CalendarDate

	RETURN @RESULT
END
GO
