USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Common].[TimeSecToStr]
(
	@TIME BIGINT
)
RETURNS NVARCHAR(128)
AS
BEGIN
	DECLARE @RESULT NVARCHAR(128)

	SET @RESULT = ' '

	IF ROUND(@TIME / 86400, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(NVARCHAR(32), ROUND(@TIME / 86400, 0)) + ' �. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 86400, 0) * 86400, 0)
	END
	IF ROUND(@TIME / 3600, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(NVARCHAR(32), ROUND(@TIME / 3600, 0)) + ' �. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 3600, 0) * 3600, 0)
	END
	IF ROUND(@TIME / 60, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(NVARCHAR(32), ROUND(@TIME / 60, 0)) + ' �. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 60, 0) * 60, 0)
	END
	IF 	ROUND(@TIME, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(NVARCHAR(32), ROUND(@TIME, 0)) + ' c. '
		SET @TIME = 0
	END

	RETURN RTRIM(@RESULT)
END