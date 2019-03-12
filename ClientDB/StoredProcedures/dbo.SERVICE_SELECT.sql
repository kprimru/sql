USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SERVICE_SELECT]
	@FILTER		VARCHAR(100) = NULL,
	@DISMISS	BIT = 0
AS
BEGIN
	SET NOCOUNT ON;	

	SELECT 
		ServiceID, ServiceName, a.ServicePositionID, ServicePositionName, ManagerName, ServicePhone, ServiceLogin, ServiceFirst,
		(
			SELECT COUNT(*)
			FROM dbo.ClientTable
			WHERE ClientServiceID = ServiceID
				AND StatusID = 2
				AND STATUS = 1
		) AS ServiceCount,
		REVERSE(STUFF(REVERSE(
			(
				SELECT CT_NAME + ', '
				FROM 
					dbo.City
					INNER JOIN dbo.ServiceCity ON CT_ID = ID_CITY
				WHERE ID_SERVICE = ServiceID
				ORDER BY CT_DISPLAY DESC, CT_NAME FOR XML PATH('')
			)
		), 1, 2, '')) AS CT_NAME
	FROM 
		dbo.ServiceTable a
		INNER JOIN dbo.ServicePositionTable b ON a.ServicePositionID = b.ServicePositionID
		INNER JOIN dbo.ManagerTable c ON c.ManagerID = a.ManagerID
	WHERE (@FILTER IS NULL
		OR ServiceName LIKE @FILTER
		OR ServiceFullName LIKE @FILTER
		OR ServiceLogin LIKE @FILTER)
		AND (@DISMISS = 1 OR ServiceDismiss IS NULL)
	ORDER BY ServiceName
END