USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[SubhostByComment]
(
	@COMMENT	VARCHAR(200),
	@DISTR		INT
)
RETURNS VARCHAR(10)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @RES VARCHAR(10)

	SET @RES = ''

	DECLARE @TEMP VARCHAR(200)

	SET @COMMENT = ISNULL(@COMMENT, '')

	IF @DISTR <> 20
	BEGIN
		IF CHARINDEX('(', @COMMENT) <> 1
			RETURN @RES

		SET @TEMP = SUBSTRING(@COMMENT, CHARINDEX('(', @COMMENT) + 1, LEN(@COMMENT) - CHARINDEX('(', @COMMENT))

		IF CHARINDEX(')', @TEMP) < 2
			RETURN @RES

		SET @TEMP = SUBSTRING(@TEMP, 1, CHARINDEX(')', @TEMP) - 1)
	END
	ELSE
	BEGIN
		SET @COMMENT = REVERSE(@COMMENT)

		IF CHARINDEX(')', @COMMENT) <> 1
			RETURN @RES

		SET @TEMP = SUBSTRING(@COMMENT, CHARINDEX(')', @COMMENT) + 1, LEN(@COMMENT) - CHARINDEX('(', @COMMENT))

		IF (CHARINDEX('(', @TEMP) < 2) OR (CHARINDEX('(', @TEMP) > 5)
			RETURN @RES

		SET @TEMP = SUBSTRING(@TEMP, 1, CHARINDEX('(', @TEMP) - 1)

		SET @TEMP = REVERSE(@TEMP)
	END

	RETURN @TEMP
END