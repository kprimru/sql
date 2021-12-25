﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FileByteSizeToStr]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[FileByteSizeToStr] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [dbo].[FileByteSizeToStr]
(
	@SIZE BIGINT
)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @RESULT NVARCHAR(100)

	SET @RESULT = ' '

	IF ROUND(@SIZE / 1099511627776, 0) <> 0
		SET @RESULT = CONVERT(VARCHAR(20), ROUND(CAST(@SIZE AS FLOAT) / 1099511627776, 2)) + ' Тб'
	ELSE IF ROUND(@SIZE / 1073741824, 0) <> 0
		SET @RESULT = CONVERT(VARCHAR(20), ROUND(CAST(@SIZE AS FLOAT) / 1073741824, 2)) + ' Гб'
	ELSE IF ROUND(@SIZE / 1048576, 0) <> 0
		SET @RESULT = CONVERT(VARCHAR(20), ROUND(CAST(@SIZE AS FLOAT) / 1048576, 2)) + ' Мб'
	ELSE IF ROUND(@SIZE / 1024, 0) <> 0
		SET @RESULT = CONVERT(VARCHAR(20), ROUND(CAST(@SIZE AS FLOAT) / 1024, 2)) + ' Кб'
	ELSE
		SET @RESULT = CONVERT(VARCHAR(20), @SIZE) + ' байт'

	RETURN RTRIM(@RESULT)
END
GO
