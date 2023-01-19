﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[TimeMinToStr]', 'FN') IS NULL EXEC('CREATE FUNCTION [Common].[TimeMinToStr] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Common].[TimeMinToStr]
(
	@TIME INT
)
RETURNS NVARCHAR(64)
AS
BEGIN
	DECLARE @RESULT NVARCHAR(64)

	SET @RESULT = ''

	IF ROUND(@TIME / 60, 0) <> 0
		SET @RESULT = @RESULT + CONVERT(NVARCHAR(32), ROUND(@TIME / 60, 0)) + ' ч.'
	IF ROUND((@TIME - ROUND(@TIME / 60, 0) * 60), 0) <> 0
		SET @RESULT = @RESULT + CONVERT(NVARCHAR(32), ROUND((@TIME - ROUND(@TIME / 60, 0) * 60), 0)) + ' м.'

	RETURN @RESULT
END
GO
