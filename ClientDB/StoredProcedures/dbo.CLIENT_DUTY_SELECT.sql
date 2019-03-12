USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DUTY_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
		ClientDutyID, 
		ClientDutyDateTime, 
		ClientDutySurname + ISNULL(' ' + ClientDutyName, '') + ISNULL(' ' + ClientDutyPatron, '') + ISNULL('   ' + ClientDutyPhone, '') AS ClientDutyContact,
		ClientDutyPos, ClientDutyPhone, 
		DutyName, CallTypeName, 
		ClientDutyQuest, ClientDutyDocs, 
		ClientDutyNPO, ClientDutyComplete, ClientDutyUncomplete, 
		ClientDutyComment, ClientDutyGive, ClientDutyAnswer,
		REVERSE(STUFF(REVERSE(
			(
				SELECT SystemShortName + ','
				FROM 
					dbo.SystemTable z
					INNER JOIN dbo.ClientDutyIBTable y ON z.SystemID = y.SystemID
				WHERE y.ClientDutyID = a.ClientDutyID
				ORDER BY SystemOrder FOR XML PATH('')
			)), 1, 1, '')
		) AS IBList,
		d.NAME AS GR_NAME,
		ClientDutyClaimDate, ClientDutyClaimNum, 
		ClientDutyClaimAnswer, ClientDutyClaimComment,
		ANSWER, ANSWER_NOTE, SATISF, SATISF_NOTE, NOTIFY, NOTIFY_NOTE, NOTIFY_TYPE,
		CONVERT(NVARCHAR(32), e.UPD_DATE, 104) + ' ' + CONVERT(NVARCHAR(32), e.UPD_DATE, 108) + '     ' + e.UPD_USER AS RESULT_DATA,
		CONVERT(NVARCHAR(32), e.UPD_DATE, 104) + ' ' + CONVERT(NVARCHAR(32), e.UPD_DATE, 108) + '     ' + e.UPD_USER AS UPD_DATA,
		CONVERT(NVARCHAR(32), g.UPD_DATE, 104) + ' ' + CONVERT(NVARCHAR(32), g.UPD_DATE, 108) + '     ' + g.UPD_USER AS NOTIFY_DATA,
		f.NAME AS DIR_NAME
	FROM 
		dbo.ClientDutyTable a
		INNER JOIN dbo.DutyTable b ON a.DutyID = b.DutyID
		LEFT OUTER JOIN dbo.CallTypeTable c ON a.CallTypeID = c.CallTypeID
		LEFT OUTER JOIN dbo.DocumentGrantType d ON d.ID = a.ID_GRANT_TYPE
		LEFT OUTER JOIN dbo.ClientDutyResult e ON e.ID_DUTY = a.ClientDutyID AND e.STATUS = 1
		LEFT OUTER JOIN dbo.ClientDutyNotify g ON g.ID_DUTY = a.ClientDutyID AND g.STATUS = 1
		LEFT OUTER JOIN dbo.CallDirection f ON f.ID = a.ID_DIRECTION
	WHERE ClientID = @CLIENT AND a.STATUS = 1
	ORDER BY ClientDutyDateTime DESC
END