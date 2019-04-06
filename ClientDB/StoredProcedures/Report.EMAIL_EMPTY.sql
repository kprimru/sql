USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[EMAIL_EMPTY]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ClientFullName AS [Название клиента],
		b.ServiceName AS [СИ],
		b.ManagerName AS [Руководитель]
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
	WHERE a.StatusID = 2 AND ISNULL(RTRIM(LTRIM(ClientEMail)), '') = ''
	ORDER BY ManagerName, ServiceName, a.ClientFullName
END
