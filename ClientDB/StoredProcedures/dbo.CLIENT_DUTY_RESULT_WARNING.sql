USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DUTY_RESULT_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		b.ClientID, ClientFullName, 
		ClientDutyDateTime,
		DutyName, 
		ClientDutyNPO, ClientDutyComment
	FROM 
		dbo.ClientDutyTable a
		INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID 
		INNER JOIN dbo.DutyTable c ON c.DutyID = a.DutyID 
	WHERE ClientDutyComplete = 1 AND a.STATUS = 1
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientDutyResult z
				WHERE z.ID_DUTY = a.ClientDutyID
				
			)
		AND ClientDutyDateTime >= '20170101'
	ORDER BY ClientDutyDateTime DESC, ClientFullName
END
