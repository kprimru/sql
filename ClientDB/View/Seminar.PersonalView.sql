USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[PersonalView]', 'V ') IS NULL EXEC('CREATE VIEW [Seminar].[PersonalView]  AS SELECT 1')
GO
ALTER VIEW [Seminar].[PersonalView]
WITH SCHEMABINDING
AS
	SELECT
		a.ID, ID_SCHEDULE, ClientID, ClientFullName, a.SURNAME, a.NAME, a.PATRON,
		CASE
			WHEN a.SURNAME IS NULL THEN a.PSEDO + ' (' + a.EMAIL + ')'
			ELSE
				(a.SURNAME + ' ' + a.NAME + ' ' + a.PATRON)
		END AS FIO,
		a.EMAIL, a.PSEDO,
		POSITION, PHONE, NOTE,
		a.UPD_DATE, a.UPD_USER,
		a.ID_STATUS, c.NAME AS STAT_NAME, c.COLOR, c.INDX,
		ServiceName, ServiceID,
		ServiceStatusIndex,
		ID_SUBJECT, CONFIRM_DATE, CONFIRM_STATUS, INVITE_NUM
	FROM
		Seminar.Personal a
		INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = b.ClientID
		INNER JOIN Seminar.Status c ON a.ID_STATUS = c.ID
		INNER JOIN dbo.ServiceTable d ON d.ServiceID = b.ClientServiceID
		INNER JOIN dbo.ServiceStatusTable e ON e.ServiceStatusID = b.StatusID
		INNER JOIN Seminar.Schedule f ON f.ID = a.ID_SCHEDULE
	WHERE a.STATUS = 1
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Seminar.PersonalView(ID)] ON [Seminar].[PersonalView] ([ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Seminar.PersonalView(ClientID)] ON [Seminar].[PersonalView] ([ClientID] ASC);
CREATE NONCLUSTERED INDEX [IX_Seminar.PersonalView(ID_SCHEDULE)] ON [Seminar].[PersonalView] ([ID_SCHEDULE] ASC);
CREATE NONCLUSTERED INDEX [IX_Seminar.PersonalView(ID_SUBJECT)+(ClientID,ClientFullName,FIO,INDX)] ON [Seminar].[PersonalView] ([ID_SUBJECT] ASC) INCLUDE ([ClientID], [ClientFullName], [FIO], [INDX]);
GO
