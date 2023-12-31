USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[USR_PARSE]
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



	SET @FL_NAME = RIGHT(@FL_NAME, CHARINDEX('\', REVERSE(@FL_NAME)) - 1)

	SET @TIME = RIGHT(@FL_NAME, 8)

	SET @FL_NAME = LEFT(@FL_NAME, LEN(@FL_NAME) - 9)

	SET @DATE = RIGHT(@FL_NAME, 10)

	SET @FL_NAME = LEFT(@FL_NAME, LEN(@FL_NAME) - 11)

	--SET @COMPLECT = RIGHT(@FL_NAME, CHARINDEX('\', REVERSE(@FL_NAME)) - 1)

	SET @FL_NAME = REPLACE(@FL_NAME, 'CONS#', '')

	SET @COMPLECT = @FL_NAME


	SET @SYS = LEFT(@COMPLECT, CHARINDEX('_', @COMPLECT) - 1)

	SET @FL_NAME = RIGHT(@FL_NAME, LEN(@FL_NAME) - LEN(@SYS) - 1)

	IF CHARINDEX('_', REVERSE(@FL_NAME)) <> 0
		SET @COMP = REVERSE(LEFT(REVERSE(@FL_NAME), CHARINDEX('_', REVERSE(@FL_NAME)) - 1))
	ELSE
		SET @COMP = 1

	IF CHARINDEX('_', REVERSE(@FL_NAME)) <> 0
		SET @DISTR = LEFT(@FL_NAME, LEN(@FL_NAME) - LEN(@COMP) - 1)
	ELSE
		SET @DISTR = @FL_NAME

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
