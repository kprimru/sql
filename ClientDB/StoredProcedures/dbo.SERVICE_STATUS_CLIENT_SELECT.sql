USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SERVICE_STATUS_CLIENT_SELECT]
	@ID	INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ServiceStatusID, ServiceStatusName, ServiceDefault
	FROM dbo.ServiceStatusTable
	WHERE ServiceStatusReg = 
		ISNULL((
			SELECT ServiceStatusReg
			FROM 
				dbo.ClientTable INNER JOIN
				dbo.ServiceStatusTable ON ServiceStatusID = StatusID
			WHERE ClientID = @ID
		), 0)
	ORDER BY ServiceStatusName	
END