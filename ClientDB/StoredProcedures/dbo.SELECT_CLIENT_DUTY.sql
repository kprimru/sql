USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SELECT_CLIENT_DUTY]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		ClientDutyID, 
		Convert(varchar(20), Convert(datetime, ClientDutyDateTime, 112), 104) AS ClientDutyDateStr, 
		ClientDutyDate, ClientDutyTime, ClientDutyDateTime, 
		ClientDutyPhone, ClientDutyPos, ClientDutyContact,
		ISNULL(ClientDutyContact + CHAR(10) + CHAR(13), '') + ISNULL(ClientDutyPos + CHAR(10) + CHAR(13), '') + ISNULL(ClientDutyPhone, '') AS DUTY_CONTACT,
		DutyName, DutyTable.DutyID, ManagerTable.ManagerID, ManagerName, 
		CallTypeName, CallTypeTable.CallTypeID,
		REVERSE(STUFF(REVERSE((
			SELECT SystemShortName + ','
			FROM 
				dbo.ClientDutyIBTable INNER JOIN
				dbo.SystemTable ON SystemTable.SystemID = ClientDutyIBTable.SystemID
			WHERE ClientDutyTable.ClientDutyID = ClientDutyIBTable.ClientDutyID
			ORDER BY SystemShortName FOR XML PATH('')
		)),1,1,'')) AS IBList,
		REVERSE(STUFF(REVERSE((
			SELECT Convert(VARCHAR(10), SystemTable.SystemID) + ','
			FROM 
				dbo.ClientDutyIBTable INNER JOIN
				dbo.SystemTable ON SystemTable.SystemID = ClientDutyIBTable.SystemID
			WHERE ClientDutyTable.ClientDutyID = ClientDutyIBTable.ClientDutyID
			ORDER BY SystemShortName FOR XML PATH('')
		)),1,1,'')) AS CheckedIB,
		ClientDutyGive, ClientDutyAnswer,
		ClientDutyQuest, ClientDutyDocs, ClientDutyNPO, ClientDutyComplete, ClientDutyUncomplete, ClientDutyComment
	FROM 
		dbo.ClientDutyTable LEFT OUTER JOIN 
		dbo.DutyTable ON ClientDutyTable.DutyID = DutyTable.DutyID LEFT OUTER JOIN
		dbo.ManagerTable ON ManagerTable.ManagerID = ClientDutyTable.ManagerID LEFT OUTER JOIN
		dbo.CallTypeTable ON CallTypeTable.CallTypeID = ClientDutyTable.CallTypeID
	WHERE ClientID = @clientid AND STATUS = 1
	ORDER BY ClientDutyDateTime DESC
END