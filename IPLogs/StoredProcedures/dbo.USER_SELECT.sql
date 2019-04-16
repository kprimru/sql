USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USER_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [name] AS US_NAME
	FROM sys.database_principals 
	WHERE [type] IN ('U', 'S')
		AND [name] NOT IN ('dbo', 'guest', 'sys', 'INFORMATION_SCHEMA')
	ORDER BY US_NAME
END
