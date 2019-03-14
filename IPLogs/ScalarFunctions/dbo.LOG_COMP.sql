USE [IPLogs]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE FUNCTION [dbo].[LOG_COMP]
(
	@NAME	NVARCHAR(512)
)
RETURNS TINYINT
AS
BEGIN
	DECLARE @RESULT	TINYINT

	SET @RESULT = dbo.LOG_PARSE(@NAME, 'COMP')

	RETURN @RESULT
END
