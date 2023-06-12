﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FileSizeToStr]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[FileSizeToStr] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[FileSizeToStr]
(
	@SIZE BIGINT
)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @RESULT NVARCHAR(50)

	IF ROUND(@SIZE / 1048576, 0) <> 0
		SET @RESULT = CONVERT(VARCHAR(20), ROUND(CAST(@SIZE AS FLOAT) / 1048576, 2)) + ' ТБ'
	ELSE IF ROUND(@SIZE / 1024, 0) <> 0
		SET @RESULT = CONVERT(VARCHAR(20), ROUND(CAST(@SIZE AS FLOAT) / 1024, 2)) + ' ГБ'
	ELSE
		SET @RESULT = CONVERT(VARCHAR(20), @SIZE) + ' МБ'

	RETURN @RESULT
END
GO
