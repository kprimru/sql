USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientWorkView]
AS
	SELECT ClientID, '������� ���������' AS TP, EventDate AS DT, EventComment AS NOTE, EventCreateUser AS AUTHOR
	FROM dbo.EventTable
	WHERE EventActive = 1 AND EventID = MasterID

	UNION ALL

	SELECT ID_CLIENT, '��������', DATE, NOTE, UPD_USER
	FROM dbo.ClientStudy
	WHERE STATUS = 1

	UNION ALL

	SELECT CL_ID, '������ �����������', CR_DATE, CR_CONDITION, CR_CREATE_USER
	FROM dbo.ClientRival
	WHERE CR_ACTIVE = 1 AND CR_ID = CR_ID_MASTER

	UNION ALL

	SELECT ClientID, '�������� ������', dbo.DateOf(ClientDutyDateTime), ClientDutyQuest, UPD_USER
	FROM dbo.ClientDutyTable
	WHERE STATUS = 1

	UNION ALL

	SELECT CC_ID_CLIENT, '�������������', CC_DATE, CT_NOTE, CC_USER
	FROM dbo.ClientTrustView WITH(NOEXPAND)

	UNION ALL

	SELECT CC_ID_CLIENT, '�����������������', CC_DATE, CS_NOTE, CC_USER
	FROM
		dbo.ClientSatisfaction
		INNER JOIN dbo.ClientCall ON CC_ID = CS_ID_CALL

