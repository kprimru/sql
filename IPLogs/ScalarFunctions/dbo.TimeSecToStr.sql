USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[TimeSecToStr]
(
	@TIME INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @RESULT NVARCHAR(50)

	SET @RESULT = ''

	IF ROUND(@TIME / 3600, 0) <> 0
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME / 3600, 0)) + ' �.'
	IF ROUND((@TIME - ROUND(@TIME / 3600, 0) * 3600) / 60, 0) <> 0
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND((@TIME - ROUND(@TIME / 3600, 0) * 3600) / 60, 0)) + ' �.'
	IF 	ROUND(@TIME - ROUND(@TIME / 3600, 0) * 3600 - ROUND((@TIME - ROUND(@TIME / 3600, 0) * 3600) / 60, 0) * 60, 0) <> 0
		SET @RESULT = @RESULT + CONVERT(VARCHAR(20), ROUND(@TIME - ROUND(@TIME / 3600, 0) * 3600 - ROUND((@TIME - ROUND(@TIME / 3600, 0) * 3600) / 60, 0) * 60, 0)) + ' c.'

	RETURN @RESULT
END
