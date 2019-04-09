USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[INNOVATION_EMPTY]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @INN UNIQUEIDENTIFIER

	SELECT TOP 1 @INN = ID
	FROM dbo.Innovation
	ORDER BY START DESC


	SELECT ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientFullName AS [Клиент]
	FROM 
		dbo.ClientInnovation a
		INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ID_CLIENT = ClientID
	WHERE ID_INNOVATION = @INN
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientInnovationPersonal b
				WHERE b.ID_INNOVATION = a.ID
			)
	ORDER BY ManagerName, ServiceName, ClientFullName
END
