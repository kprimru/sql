USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SELECT_SERVICE]
	@managerid	INT,
	@ACTIVE		BIT = 0
AS
BEGIN
	SET NOCOUNT ON

	SELECT ServiceName, ServicePositionName, ServiceCount
	FROM
		(
			SELECT 
				ServiceName, ServicePositionName,
				(
					SELECT COUNT(ClientID)
					FROM dbo.ClientTable z
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON z.StatusId = s.ServiceStatusId
					WHERE z.STATUS = 1 AND z.ClientServiceID = a.ServiceID
				) AS ServiceCount
			FROM 
				dbo.ServiceTable a
				LEFT OUTER JOIN	dbo.ServicePositionTable b ON a.ServicePositionID = b.ServicePositionID
			WHERE ManagerID = @managerid
		) AS o_O
	WHERE (@ACTIVE = 0 OR ServiceCount <> 0)
	ORDER BY ServiceName
END