﻿USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FileSizeToStr]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[FileSizeToStr] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[FileSizeToStr]
(
	@SIZE	BIGINT
)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @RESULT NVARCHAR(50)

	IF ROUND(@SIZE / CONVERT(BIGINT, 1099511627776), 0) <> 0
		SET @RESULT = CONVERT(VARCHAR(20), ROUND(CAST(@SIZE AS FLOAT) / CONVERT(BIGINT, 1099511627776), 2)) + ' Тб'
	ELSE IF ROUND(@SIZE / 1073741824, 0) <> 0
		SET @RESULT = CONVERT(VARCHAR(20), ROUND(CAST(@SIZE AS FLOAT) / 1073741824, 2)) + ' Гб'
	ELSE IF ROUND(@SIZE / 1048576, 0) <> 0
		SET @RESULT = CONVERT(VARCHAR(20), ROUND(CAST(@SIZE AS FLOAT) / 1048576, 2)) + ' Мб'
	ELSE IF ROUND(@SIZE / 1024, 0) <> 0
		SET @RESULT = CONVERT(VARCHAR(20), ROUND(CAST(@SIZE AS FLOAT) / 1024, 2)) + ' Кб'
	ELSE
		SET @RESULT = CONVERT(VARCHAR(20), @SIZE) + ' байт'

	RETURN @RESULT
END
GO
