USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[TimeMilliSecToStr]
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
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME / 86400000, 0)) + ' �. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 86400000, 0) * 86400000, 0)
	END	
	IF ROUND(@TIME / 3600000, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME / 3600000, 0)) + ' �. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 3600000, 0) * 3600000, 0)
	END
	IF ROUND(@TIME / 60000, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME / 60000, 0)) + ' �. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 60000, 0) * 60000, 0)
	END
	IF ROUND(@TIME / 1000, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME / 1000, 0)) + ' �. '
		SET @TIME = ROUND(@TIME - ROUND(@TIME / 1000, 0) * 1000, 0)
	END
	IF 	ROUND(@TIME, 0) <> 0
	BEGIN
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME, 0)) + ' ��. '
		SET @TIME = 0
	END
	
	RETURN RTRIM(@RESULT)
END