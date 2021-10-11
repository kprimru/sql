USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Debug].[Execution:Params@Parse]
(
	@Params Xml
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[Row:Index] = 1,
		[Name]		= 'Name',
		[Value]		= 'Value'
)
GO
