USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientWorkView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientWorkView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [dbo].[ClientWorkView]
AS
	SELECT ClientID, 'История посещений' AS TP, EventDate AS DT, EventComment AS NOTE, EventCreateUser AS AUTHOR
	FROM dbo.EventTable
	WHERE EventActive = 1 AND EventID = MasterID

	UNION ALL

	SELECT ID_CLIENT, 'Обучение', DATE, NOTE, UPD_USER
	FROM dbo.ClientStudy
	WHERE STATUS = 1

	UNION ALL

	SELECT CL_ID, 'Угрозы конкурентов', CR_DATE, CR_CONDITION, CR_CREATE_USER
	FROM dbo.ClientRival
	WHERE CR_ACTIVE = 1 AND CR_ID = CR_ID_MASTER

	UNION ALL

	SELECT ClientID, 'Дежурная служба', dbo.DateOf(ClientDutyDateTime), ClientDutyQuest, UPD_USER
	FROM dbo.ClientDutyTable
	WHERE STATUS = 1

	UNION ALL

	SELECT CC_ID_CLIENT, 'Достоверность', CC_DATE, CT_NOTE, CC_USER
	FROM dbo.ClientTrustView WITH(NOEXPAND)

	UNION ALL

	SELECT CC_ID_CLIENT, 'Удовлетворенность', CC_DATE, CS_NOTE, CC_USER
	FROM
		dbo.ClientSatisfaction
		INNER JOIN dbo.ClientCall ON CC_ID = CS_ID_CALL

GO
