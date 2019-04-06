USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SELECT_EMPTY_CLIENT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ClientID, ClientFullName, ClientShortName, ServiceStatusName
	FROM 
		dbo.ClientTable a INNER JOIN
		dbo.ServiceStatusTable b ON b.ServiceStatusID = a.StatusID
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ClientSystemsTable b
			WHERE a.ClientID = b.ClientID
		)
	ORDER BY ClientFullName
END