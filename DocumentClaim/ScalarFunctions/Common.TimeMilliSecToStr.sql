﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Common].[TimeMilliSecToStr]
(
	@TIME BIGINT
)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @RESULT NVARCHAR(100)

	SET @RESULT = ' '

	IF ROUND(@TIME / 86400000, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME / 86400000, 0)) + ' д. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 86400000, 0) * 86400000, 0)
	END
	IF ROUND(@TIME / 3600000, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME / 3600000, 0)) + ' ч. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 3600000, 0) * 3600000, 0)
	END
	IF ROUND(@TIME / 60000, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME / 60000, 0)) + ' м. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 60000, 0) * 60000, 0)
	END
	IF ROUND(@TIME / 1000, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME / 1000, 0)) + ' с. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 1000, 0) * 1000, 0)
	END
	IF 	ROUND(@TIME, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME, 0)) + ' мс. '
		SET @TIME = 0
	END

	RETURN RTRIM(@RESULT)
END
GO