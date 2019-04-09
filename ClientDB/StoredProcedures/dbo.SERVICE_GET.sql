USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ServiceName, ServicePositionID, ManagerID, ServicePhone, ServiceLogin, ServiceFullName,
		('<LIST>' + 
			(
				SELECT '{' + CONVERT(VARCHAR(50), ID_CITY) + '}' AS ITEM
				FROM dbo.ServiceCity
				WHERE ID_SERVICE = ServiceID
				ORDER BY ID_CITY FOR XML PATH('')
			) 
		+ '</LIST>') AS CT_LIST
	FROM 
		dbo.ServiceTable
	WHERE ServiceID = @ID
END