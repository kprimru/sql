USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_PERSONAL_OTHER_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF OBJECT_ID('tempdb..#personal') IS NOT NULL
			DROP TABLE #personal

		CREATE TABLE #personal
			(
				TP	BIT,
				SURNAME	NVARCHAR(256),
				NAME	NVARCHAR(256),
				PATRON	NVARCHAR(256),
				POS		NVARCHAR(256),
				PHONE	NVARCHAR(256),
				FRM		NVARCHAR(64),
				DATE	DATETIME
			)
			
		INSERT INTO #personal(TP, SURNAME, NAME, PATRON, POS, FRM)	
			SELECT 1, CP_SURNAME, CP_NAME, CP_PATRON, CP_POS, ''
			FROM 
				dbo.ClientPersonal
			WHERE CP_ID_CLIENT = @CLIENT		
					
		INSERT INTO #personal(TP, SURNAME, NAME, PATRON, POS, PHONE, FRM, DATE)
			SELECT DISTINCT 
				0, ISNULL(ClientDutySurname, ''), ISNULL(ClientDutyName, ''), ISNULL(ClientDutyPatron, ''), 
				(
					SELECT TOP 1 ClientDutyPos
					FROM dbo.ClientDutyTable b
					WHERE ClientID = @CLIENT
						AND b.STATUS = 1
						AND a.ClientDutySurname = b.ClientDutySurname
						AND a.ClientDutyName = b.ClientDutyName
						AND a.ClientDutyPatron = b.ClientDutyPatron
					ORDER BY ClientDutyDateTime DESC
				), 
				(
					SELECT TOP 1 ClientDutyPhone
					FROM dbo.ClientDutyTable b
					WHERE ClientID = @CLIENT
						AND b.STATUS = 1
						AND a.ClientDutySurname = b.ClientDutySurname
						AND a.ClientDutyName = b.ClientDutyName
						AND a.ClientDutyPatron = b.ClientDutyPatron
					ORDER BY ClientDutyDateTime DESC
				), 			
				'ДС',
				(
					SELECT MAX(ClientDutyDateTime)
					FROM dbo.ClientDutyTable b
					WHERE ClientID = @CLIENT
						AND b.STATUS = 1
						AND a.ClientDutySurname = b.ClientDutySurname
						AND a.ClientDutyName = b.ClientDutyName
						AND a.ClientDutyPatron = b.ClientDutyPatron
				)
			FROM 
				dbo.ClientDutyTable a
			WHERE ClientID = @CLIENT
				AND a.STATUS = 1
				AND ISNULL(ClientDutyName, '') <> ''
				AND NOT EXISTS
					(
						SELECT *
						FROM #personal
						WHERE SURNAME = ClientDutySurname AND NAME = ClientDutyName AND PATRON = ClientDutyPatron
					)

		INSERT INTO #personal(TP, SURNAME, NAME, PATRON, POS, PHONE, FRM, DATE)					
			SELECT DISTINCT 
				0, SURNAME, NAME, PATRON, 
				(
					SELECT TOP 1 POSITION
					FROM Seminar.PersonalView z WITH(NOEXPAND)
					WHERE z.ClientID = @CLIENT AND z.SURNAME = a.SURNAME AND z.NAME = a.NAME AND z.PATRON = a.PATRON				
					ORDER BY UPD_DATE DESC
				), 
				(
					SELECT TOP 1 PHONE
					FROM Seminar.PersonalView z WITH(NOEXPAND)
					WHERE z.ClientID = @CLIENT AND z.SURNAME = a.SURNAME AND z.NAME = a.NAME AND z.PATRON = a.PATRON				
					ORDER BY UPD_DATE DESC
				), 
				'Семинар',
				(
					SELECT MAX(UPD_DATE)
					FROM Seminar.PersonalView z WITH(NOEXPAND)
					WHERE z.ClientID = @CLIENT AND z.SURNAME = a.SURNAME AND z.NAME = a.NAME AND z.PATRON = a.PATRON				
				)
			FROM 
				Seminar.PersonalView a WITH(NOEXPAND)
			WHERE ClientID = @CLIENT
				AND NOT EXISTS
					(
						SELECT *
						FROM #personal z
						WHERE a.SURNAME = z.SURNAME AND a.NAME = z.NAME AND a.PATRON = z.PATRON
					)

		/*
		INSERT INTO #personal(TP, SURNAME, NAME, PATRON, POS, PHONE, FRM, DATE)			
			SELECT DISTINCT 
				0, SR_SURNAME, SR_NAME, SR_PATRON, 
				(
					SELECT TOP 1 SR_POS
					FROM 
						Training.SeminarReserve b
						INNER JOIN Training.TrainingSubject c ON TS_ID = SR_ID_SUBJECT
						INNER JOIN Training.TrainingSchedule d ON d.TSC_ID_TS = c.TS_ID
					WHERE SR_ID_CLIENT = @CLIENT
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
					WHERE SR_ID_CLIENT = @CLIENT
						AND a.SR_SURNAME = b.SR_SURNAME 
						AND a.SR_NAME = b.SR_NAME
						AND a.SR_PATRON = b.SR_PATRON
					ORDER BY TSC_DATE
				),
				'Семинар',
				(				
					SELECT MAX(TSC_DATE)
					FROM 
						Training.SeminarReserve b
						INNER JOIN Training.TrainingSubject c ON TS_ID = SR_ID_SUBJECT
						INNER JOIN Training.TrainingSchedule d ON d.TSC_ID_TS = c.TS_ID
					WHERE SR_ID_CLIENT = @CLIENT
						AND a.SR_SURNAME = b.SR_SURNAME 
						AND a.SR_NAME = b.SR_NAME
						AND a.SR_PATRON = b.SR_PATRON
				)
			FROM Training.SeminarReserve a
			WHERE SR_ID_CLIENT = @CLIENT
				AND NOT EXISTS
					(
						SELECT *
						FROM #personal
						WHERE SURNAME = SR_SURNAME AND NAME = SR_NAME AND PATRON = SR_PATRON
					)
			
		INSERT INTO #personal(TP, SURNAME, NAME, PATRON, POS, PHONE, FRM, DATE)					
			SELECT DISTINCT 
				0, SSP_SURNAME, SSP_NAME, SSP_PATRON, 
				(
					SELECT TOP 1 SSP_POS
					FROM
						Training.SeminarSignPersonal p
						INNER JOIN Training.SeminarSign q ON q.SP_ID = p.SSP_ID_SIGN
						INNER JOIN Training.TrainingSchedule ON TSC_ID = SP_ID_SEMINAR
					WHERE q.SP_ID_CLIENT = @CLIENT AND p.SSP_SURNAME = a.SSP_SURNAME AND p.SSP_NAME = a.SSP_NAME AND p.SSP_PATRON = a.SSP_PATRON
					ORDER BY TSC_DATE DESC
				), 
				(
					SELECT TOP 1 SSP_PHONE
					FROM
						Training.SeminarSignPersonal p
						INNER JOIN Training.SeminarSign q ON q.SP_ID = p.SSP_ID_SIGN
						INNER JOIN Training.TrainingSchedule ON TSC_ID = SP_ID_SEMINAR
					WHERE q.SP_ID_CLIENT = @CLIENT AND p.SSP_SURNAME = a.SSP_SURNAME AND p.SSP_NAME = a.SSP_NAME AND p.SSP_PATRON = a.SSP_PATRON
					ORDER BY TSC_DATE DESC
				), 
				'Семинар',
				(
					SELECT MAX(TSC_DATE)
					FROM
						Training.SeminarSignPersonal p
						INNER JOIN Training.SeminarSign q ON q.SP_ID = p.SSP_ID_SIGN
						INNER JOIN Training.TrainingSchedule ON TSC_ID = SP_ID_SEMINAR
					WHERE q.SP_ID_CLIENT = @CLIENT AND p.SSP_SURNAME = a.SSP_SURNAME AND p.SSP_NAME = a.SSP_NAME AND p.SSP_PATRON = a.SSP_PATRON				
				)
			FROM 
				Training.SeminarSignPersonal a
				INNER JOIN Training.SeminarSign b ON SP_ID = SSP_ID_SIGN
			WHERE SP_ID_CLIENT = @CLIENT
				AND NOT EXISTS
					(
						SELECT *
						FROM #personal
						WHERE SURNAME = SSP_SURNAME AND NAME = SSP_NAME AND PATRON = SSP_PATRON
					)
		*/

		INSERT INTO #personal(TP, SURNAME, NAME, PATRON, POS, PHONE, FRM, DATE)
			SELECT DISTINCT 
				0, b.SURNAME, b.NAME, b.PATRON, 
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
				),
				'Заявка на обучение',
				(
					SELECT MAX(DATE)
					FROM 
						dbo.ClientStudyClaim p
						INNER JOIN dbo.ClientStudyClaimPeople q ON p.ID = q.ID_CLAIM
					WHERE p.ID_CLIENT = a.ID_CLIENT AND q.SURNAME = b.SURNAME AND q.NAME = b.NAME AND q.PATRON = b.PATRON AND STATUS = 1
				)
			FROM
				dbo.ClientStudyClaim a
				INNER JOIN dbo.ClientStudyClaimPeople b ON a.ID = b.ID_CLAIM
			WHERE ID_CLIENT = @CLIENT --AND DATE >= DATEADD(YEAR, -2, dbo.DateOf(GETDATE()))
				AND STATUS = 1
				AND NOT EXISTS
					(
						SELECT *
						FROM #personal z
						WHERE b.SURNAME = z.SURNAME AND b.NAME = z.NAME AND b.PATRON = z.PATRON
					)

		INSERT INTO #personal(TP, SURNAME, NAME, PATRON, POS, FRM, DATE)
			SELECT DISTINCT 
				0, b.SURNAME, b.NAME, b.PATRON, 
				(
					SELECT TOP 1 POSITION 
					FROM 
						dbo.ClientStudy p
						INNER JOIN dbo.ClientStudyPeople q ON p.ID = q.ID_STUDY
					WHERE p.ID_CLIENT = a.ID_CLIENT AND q.SURNAME = b.SURNAME AND q.NAME = b.NAME AND q.PATRON = b.PATRON AND STATUS = 1
					ORDER BY DATE DESC
				),
				'Обученный',
				(
					SELECT MAX(DATE)
					FROM 
						dbo.ClientStudy p
						INNER JOIN dbo.ClientStudyPeople q ON p.ID = q.ID_STUDY
					WHERE p.ID_CLIENT = a.ID_CLIENT AND q.SURNAME = b.SURNAME AND q.NAME = b.NAME AND q.PATRON = b.PATRON AND STATUS = 1
				)
			FROM
				dbo.ClientStudy a
				INNER JOIN dbo.ClientStudyPeople b ON a.ID = b.ID_STUDY
			WHERE ID_CLIENT = @CLIENT --AND DATE >= DATEADD(YEAR, -2, dbo.DateOf(GETDATE()))
				AND STATUS = 1
				AND NOT EXISTS
					(
						SELECT *
						FROM #personal z
						WHERE b.SURNAME = z.SURNAME AND b.NAME = z.NAME AND b.PATRON = z.PATRON
					)	

		DELETE FROM #personal WHERE TP = 1

		DELETE FROM #personal WHERE SURNAME = '' AND NAME = '' AND PATRON = ''

		SELECT SURNAME, NAME, PATRON, POS, FRM, ISNULL(SURNAME + ' ', '') + ISNULL(NAME + ' ', '') + ISNULL(PATRON, '') AS FIO, PHONE, DATE
		FROM #personal
		ORDER BY SURNAME, NAME, PATRON

		IF OBJECT_ID('tempdb..#personal') IS NOT NULL
			DROP TABLE #personal
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
