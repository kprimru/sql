USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DUTY_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		b.ClientID, ClientFullName, 
		ClientDutyDateTime,
		DutyName, CallTypeName,
		ClientDutyNPO, ClientDutyComment, e.NAME
	FROM 
		dbo.ClientDutyTable a
		INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID 
		INNER JOIN dbo.DutyTable c ON c.DutyID = a.DutyID 
		LEFT OUTER JOIN dbo.CallTypeTable d ON d.CallTypeID = a.CallTypeID
		LEFT OUTER JOIN dbo.CallDirection e ON e.ID = a.ID_DIRECTION
	WHERE ClientDutyComplete = 0 AND a.STATUS = 1
	ORDER BY ClientDutyDateTime DESC, ClientFullName
END