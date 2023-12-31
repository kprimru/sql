USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[LOG_TYPE]
(
	@NAME	NVARCHAR(512)
)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @RESULT	VARCHAR(10)

	SET @RESULT = dbo.LOG_PARSE(@NAME, 'TYPE')

	RETURN @RESULT
END
GO
