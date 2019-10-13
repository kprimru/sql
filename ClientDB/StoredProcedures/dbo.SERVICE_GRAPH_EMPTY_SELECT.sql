USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_GRAPH_EMPTY_SELECT]
	@SERVICE	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ClientID, ClientFullName, ClientFullName AS ClientShortName
	FROM dbo.ClientTable a
	INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
	WHERE a.ClientServiceID = @SERVICE 
		AND a.STATUS = 1
		AND 
			(
				DayID IS NULL
				OR
				ServiceStart IS NULL
				OR
				ServiceTime IS NULL
			)
	ORDER BY ClientFullName
END
