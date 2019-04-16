USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[STATUS_SELECT]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ServiceStatusID, ServiceStatusName, ServiceStatusIndex, ServiceImage
	FROM [PC275-SQL\ALPHA].ClientDB.dbo.ServiceStatusTable
	ORDER BY ServiceStatusIndex
END
