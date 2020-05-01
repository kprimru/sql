USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Security].[ExecutionLogView]
WITH SCHEMABINDING
AS
	SELECT	LG_SCHEMA + '.' + LG_PROCEDURE AS LG_FULL, dbo.DateOf(LG_DATE) AS LG_DT, LG_USER, LG_HOST, COUNT_BIG(*) As LG_CNT
	FROM	Security.ExecutionLog
	GROUP BY LG_SCHEMA, LG_PROCEDURE, dbo.DateOf(LG_DATE), LG_USER, LG_HOST