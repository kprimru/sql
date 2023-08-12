﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientPersonalOtherView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientPersonalOtherView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [dbo].[ClientPersonalOtherView]
AS
	SELECT ClientID, SURNAME, NAME, PATRON, PHONE, POS
	FROM
		dbo.ClientTable t
		CROSS APPLY
			(
				SELECT DISTINCT
					ISNULL(ClientDutySurname, '') AS SURNAME, ISNULL(ClientDutyName, '') AS NAME, ISNULL(ClientDutyPatron, '') AS PATRON,
					(
						SELECT TOP 1 ClientDutyPos
						FROM dbo.ClientDutyTable b
						WHERE b.ClientID = t.ClientID
							AND b.STATUS = 1
							AND a.ClientDutySurname = b.ClientDutySurname
							AND a.ClientDutyName = b.ClientDutyName
							AND a.ClientDutyPatron = b.ClientDutyPatron
						ORDER BY ClientDutyDate DESC
					) AS POS,
					(
						SELECT TOP 1 ClientDutyPhone
						FROM dbo.ClientDutyTable b
						WHERE ClientID = t.ClientID
							AND b.STATUS = 1
							AND a.ClientDutySurname = b.ClientDutySurname
							AND a.ClientDutyName = b.ClientDutyName
							AND a.ClientDutyPatron = b.ClientDutyPatron
						ORDER BY ClientDutyDate DESC
					) AS PHONE
				FROM
					dbo.ClientDutyTable a
				WHERE a.ClientID = t.ClientID
					AND a.STATUS = 1
					AND ISNULL(ClientDutyName, '') <> ''

				UNION

				SELECT DISTINCT
					SR_SURNAME, SR_NAME, SR_PATRON,
					(
						SELECT TOP 1 SR_POS
						FROM
							Training.SeminarReserve b
							INNER JOIN Training.TrainingSubject c ON TS_ID = SR_ID_SUBJECT
							INNER JOIN Training.TrainingSchedule d ON d.TSC_ID_TS = c.TS_ID
						WHERE SR_ID_CLIENT = t.ClientID
							AND a.SR_SURNAME = b.SR_SURNAME
							AND a.SR_NAME = b.SR_NAME
							AND a.SR_PATRON = b.SR_PATRON
						ORDER BY TSC_DATE
					),
					(
						SELECT TOP 1 SR_PHONE
						FROM
							Training.SeminarReserve b
							INNER JOIN Training.TrainingSubject c ON TS_ID = SR_ID_SUBJECT
							INNER JOIN Training.TrainingSchedule d ON d.TSC_ID_TS = c.TS_ID
						WHERE SR_ID_CLIENT = t.ClientID
							AND a.SR_SURNAME = b.SR_SURNAME
							AND a.SR_NAME = b.SR_NAME
							AND a.SR_PATRON = b.SR_PATRON
						ORDER BY TSC_DATE
					)
				FROM Training.SeminarReserve a
				WHERE SR_ID_CLIENT = t.ClientID

				UNION

				SELECT DISTINCT
					SURNAME, NAME, PATRON,
					(
						SELECT TOP 1 POSITION
						FROM
							Seminar.PersonalView b WITH(NOEXPAND)
						WHERE b.ClientID = t.ClientID
							AND a.SURNAME = b.SURNAME
							AND a.NAME = b.NAME
							AND a.PATRON = b.PATRON
						ORDER BY UPD_DATE DESC
					),
					(
						SELECT TOP 1 PHONE
						FROM Seminar.PersonalView b WITH(NOEXPAND)
						WHERE b.ClientID = t.ClientID
							AND a.SURNAME = b.SURNAME
							AND a.NAME = b.NAME
							AND a.PATRON = b.PATRON
						ORDER BY UPD_DATE DESC
					)
				FROM Seminar.PersonalView a WITH(NOEXPAND)
				WHERE a.ClientID = t.ClientID

				UNION

				SELECT DISTINCT
					SSP_SURNAME, SSP_NAME, SSP_PATRON,
					(
						SELECT TOP 1 SSP_POS
						FROM
							Training.SeminarSignPersonal p
							INNER JOIN Training.SeminarSign q ON q.SP_ID = p.SSP_ID_SIGN
							INNER JOIN Training.TrainingSchedule ON TSC_ID = SP_ID_SEMINAR
						WHERE q.SP_ID_CLIENT = t.ClientID AND p.SSP_SURNAME = a.SSP_SURNAME AND p.SSP_NAME = a.SSP_NAME AND p.SSP_PATRON = a.SSP_PATRON
						ORDER BY TSC_DATE DESC
					),
					(
						SELECT TOP 1 SSP_PHONE
						FROM
							Training.SeminarSignPersonal p
							INNER JOIN Training.SeminarSign q ON q.SP_ID = p.SSP_ID_SIGN
							INNER JOIN Training.TrainingSchedule ON TSC_ID = SP_ID_SEMINAR
						WHERE q.SP_ID_CLIENT = t.ClientID AND p.SSP_SURNAME = a.SSP_SURNAME AND p.SSP_NAME = a.SSP_NAME AND p.SSP_PATRON = a.SSP_PATRON
						ORDER BY TSC_DATE DESC
					)
				FROM
					Training.SeminarSignPersonal a
					INNER JOIN Training.SeminarSign b ON SP_ID = SSP_ID_SIGN
				WHERE SP_ID_CLIENT = t.ClientID

				UNION

				SELECT DISTINCT
					b.SURNAME, b.NAME, b.PATRON,
					(
						SELECT TOP 1 POSITION
						FROM
							dbo.ClientStudyClaim p
							INNER JOIN dbo.ClientStudyClaimPeople q ON p.ID = q.ID_CLAIM
						WHERE p.ID_CLIENT = a.ID_CLIENT AND q.SURNAME = b.SURNAME AND q.NAME = b.NAME AND q.PATRON = b.PATRON AND STATUS = 1
						ORDER BY DATE DESC
					),
					(
						SELECT TOP 1 PHONE
						FROM
							dbo.ClientStudyClaim p
							INNER JOIN dbo.ClientStudyClaimPeople q ON p.ID = q.ID_CLAIM
						WHERE p.ID_CLIENT = a.ID_CLIENT AND q.SURNAME = b.SURNAME AND q.NAME = b.NAME AND q.PATRON = b.PATRON AND STATUS = 1
						ORDER BY DATE DESC
					)
				FROM
					dbo.ClientStudyClaim a
					INNER JOIN dbo.ClientStudyClaimPeople b ON a.ID = b.ID_CLAIM
				WHERE ID_CLIENT = t.ClientID --AND DATE >= DATEADD(YEAR, -2, dbo.DateOf(GETDATE()))
					AND STATUS = 1

				UNION

				SELECT DISTINCT
					b.SURNAME, b.NAME, b.PATRON,
					(
						SELECT TOP 1 POSITION
						FROM
							dbo.ClientStudy p
							INNER JOIN dbo.ClientStudyPeople q ON p.ID = q.ID_STUDY
						WHERE p.ID_CLIENT = a.ID_CLIENT AND q.SURNAME = b.SURNAME AND q.NAME = b.NAME AND q.PATRON = b.PATRON AND STATUS = 1
						ORDER BY DATE DESC
					), NULL
				FROM
					dbo.ClientStudy a
					INNER JOIN dbo.ClientStudyPeople b ON a.ID = b.ID_STUDY
				WHERE ID_CLIENT = t.ClientID --AND DATE >= DATEADD(YEAR, -2, dbo.DateOf(GETDATE()))
					AND STATUS = 1
			) AS o_O
	WHERE STATUS = 1
GO
