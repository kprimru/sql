USE [IPLogs]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE FUNCTION [dbo].[LOG_DATE]
(
	@NAME	NVARCHAR(512)
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @RESULT	DATETIME

	SET @RESULT = CONVERT(DATETIME, dbo.LOG_PARSE(@NAME, 'DATE'), 120)

	RETURN @RESULT
END
