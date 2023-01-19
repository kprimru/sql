﻿USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[LOG_PARSE]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[LOG_PARSE] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[LOG_PARSE]
(
	@STRING	NVARCHAR(512),
	@FIELD	NVARCHAR(64)
)
RETURNS NVARCHAR(64)
AS
BEGIN
	DECLARE @RESULT	NVARCHAR(64)

	DECLARE @FL_NAME NVARCHAR(512)

	DECLARE @SHORT NVARCHAR(128)

	DECLARE @TIME VARCHAR(8)
	DECLARE @DATE VARCHAR(10)

	DECLARE @TYPE	VARCHAR(10)

	DECLARE @COMPLECT VARCHAR(20)

	DECLARE @SYS VARCHAR(10)
	DECLARE @DISTR VARCHAR(10)
	DECLARE @COMP VARCHAR(10)

	SET @FL_NAME = @STRING

	SET @FL_NAME = REVERSE( RIGHT(REVERSE(@FL_NAME), LEN(@FL_NAME) - 4))

	SET @SHORT = RIGHT(@FL_NAME, CHARINDEX('\', REVERSE(@FL_NAME)) - 1)
	SET @TYPE = ''

	IF REVERSE(SUBSTRING(REVERSE(@FL_NAME), 1, 6)) IN ('result', 'letter')
	BEGIN
		SET @TYPE = REVERSE(SUBSTRING(REVERSE(@FL_NAME), 1, 6))

		SET @FL_NAME = LEFT(@FL_NAME, LEN(@FL_NAME) - 7)
	END

	SET @TIME = RIGHT(@FL_NAME, 8)

	SET @FL_NAME = LEFT(@FL_NAME, LEN(@FL_NAME) - 9)


	SET @COMPLECT = RIGHT(@FL_NAME, CHARINDEX('\', REVERSE(@FL_NAME)) - 1)

	SET @FL_NAME = LEFT(@FL_NAME, LEN(@FL_NAME) - LEN(@COMPLECT) - 1)


	SET @DATE = RIGHT(@FL_NAME, 10)

	SET @SYS = LEFT(@COMPLECT, CHARINDEX('_', @COMPLECT) - 1)

	SET @COMPLECT = RIGHT(@COMPLECT, LEN(@COMPLECT) - LEN(@SYS) - 1)

	IF CHARINDEX('_', REVERSE(@COMPLECT)) <> 0
		SET @COMP = REVERSE(LEFT(REVERSE(@COMPLECT), CHARINDEX('_', REVERSE(@COMPLECT)) - 1))
	ELSE
		SET @COMP = 1

	IF CHARINDEX('_', REVERSE(@COMPLECT)) <> 0
		SET @DISTR = LEFT(@COMPLECT, LEN(@COMPLECT) - LEN(@COMP) - 1)
	ELSE
		SET @DISTR = @COMPLECT

	DECLARE @DT DATETIME

	SET @DT = CONVERT(DATETIME,
			LEFT(@DATE, 4) + '-' + SUBSTRING(@DATE, 6, 2) + '-' + SUBSTRING(@DATE, 9, 2) +
			' ' + REPLACE(@TIME, '_', ':')
			, 120)

	IF @FIELD = 'DATE'
		SET @RESULT = CONVERT(NVARCHAR(64), @DT, 120)
	ELSE IF @FIELD = 'SYS'
		SET @RESULT = @SYS
	ELSE IF @FIELD = 'DISTR'
		SET @RESULT = @DISTR
	ELSE IF @FIELD = 'COMP'
		SET @RESULT = @COMP
	ELSE IF @FIELD = 'TYPE'
		SET @RESULT = @TYPE
	ELSE IF @FIELD = 'FILE'
		SET @RESULT = @SHORT
	ELSE
		SET @RESULT = NULL

	RETURN @RESULT
END
GO
