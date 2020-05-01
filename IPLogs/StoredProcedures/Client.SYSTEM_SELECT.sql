USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[SYSTEM_SELECT]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SystemID, SystemShortName, SystemBaseName, SystemNumber, SystemFullName
	FROM [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable
	ORDER BY SystemOrder
END
GRANT EXECUTE ON [Client].[SYSTEM_SELECT] TO rl_common;
GO