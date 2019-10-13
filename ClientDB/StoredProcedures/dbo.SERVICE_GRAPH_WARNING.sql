USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_GRAPH_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SERVICE INT
	
	SELECT @SERVICE = ServiceID
	FROM dbo.ServiceTable
	WHERE ServiceLogin = ORIGINAL_LOGIN()
	
	SELECT COUNT(*) AS CNT
	FROM
		(
			SELECT ClientID
			FROM dbo.ServiceGraphView
			WHERE ClientServiceID = @SERVICE
				AND GR_ERROR IS NOT NULL
				
			UNION ALL
			
			SELECT ClientID
			FROM 
				dbo.ClientTable a
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
		) AS o_O
END
