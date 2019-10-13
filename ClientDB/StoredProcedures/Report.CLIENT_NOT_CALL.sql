USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[CLIENT_NOT_CALL]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientFullName AS [Клиент]
	FROM dbo.ClientView a WITH(NOEXPAND)
	INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ClientTrustView WITH(NOEXPAND)
			WHERE CC_ID_CLIENT = ClientID
		) AND
		NOT EXISTS
		(
			SELECT *
			FROM 
				dbo.ClientSatisfaction
				INNER JOIN dbo.ClientCall ON CC_ID = CS_ID_CALL
			WHERE CC_ID_CLIENT = ClientID
		)
	ORDER BY ManagerName, ServiceName, ClientFullName
END
