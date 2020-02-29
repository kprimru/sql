USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[TEACHER_REPORT_RDD_CREATE]
	@begindate	SMALLDATETIME,
	@enddate	SMALLDATETIME,
	@teacher	BIT	=	0,
	@student	BIT	=	0,
	@bibl		BIT	=	0
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

		DECLARE @TBL TABLE (POS_ID UNIQUEIDENTIFIER)
		
		IF @teacher = 1
			INSERT INTO @TBL(POS_ID) 
				SELECT ID
				FROM dbo.RDDPosition
				WHERE PSEDO = 'TEACHER'
				
		IF @student = 1
			INSERT INTO @TBL(POS_ID) 
				SELECT ID
				FROM dbo.RDDPosition
				WHERE PSEDO = 'STUDENT'
		IF @bibl = 1
			INSERT INTO @TBL(POS_ID) 
				SELECT ID
				FROM dbo.RDDPosition
				WHERE PSEDO = 'LIBRARY'

		IF @teacher = 0 AND @student = 0 AND @bibl = 0
		BEGIN
			SELECT a.ClientID, ClientFullName,
				REVERSE(STUFF(REVERSE(
					(
						SELECT CONVERT(VARCHAR(20), DATE, 104) + ', '
						FROM
							(
								SELECT DISTINCT DATE
								FROM 
									dbo.ClientStudy b
								WHERE DATE BETWEEN @begindate AND @enddate 
									AND a.ClientID = b.ID_CLIENT AND STATUS = 1
							) AS o_O
						ORDER BY DATE FOR XML PATH('')
					)
				), 1, 2, '')) AS BegDate,
				ISNULL((
					SELECT COUNT(DISTINCT (SURNAME + NAME + PATRON))
					FROM dbo.ClientStudy b INNER JOIN
						dbo.ClientStudyPeople d ON b.ID = d.ID_STUDY
					WHERE DATE BETWEEN @begindate AND @enddate AND a.ClientID = b.ID_CLIENT
						AND GR_COUNT IS NULL
						AND STATUS = 1
				), 0) + 
				ISNULL((
					SELECT SUM(GR_COUNT)
					FROM dbo.ClientStudy b INNER JOIN
						dbo.ClientStudyPeople d ON b.ID = d.ID_STUDY
					WHERE STATUS = 1 AND DATE BETWEEN @begindate AND @enddate AND a.ClientID = b.ID_CLIENT
						AND GR_COUNT IS NOT NULL 
				), 0) AS StudentCount,
				dbo.GET_TEACHER_LIST(@begindate, @enddate, a.ClientID) AS TeacherName,
				dbo.GET_STUDENT_LIST(@begindate, @enddate, a.ClientID) AS StudentName,
				dbo.GET_RECOMEND_LIST(@begindate, @enddate, a.ClientID) AS Recomend,
				ServiceName,
				(
					SELECT POSITION + ', '
					FROM 
						(
							SELECT DISTINCT POSITION
							FROM
								dbo.ClientStudy b
								INNER JOIN dbo.ClientStudyPeople c ON c.ID_STUDY = b.ID	
							WHERE a.CLientID = b.ID_CLIENT AND DATE BETWEEN @begindate AND @enddate
								AND STATUS = 1
								AND POSITION <> ''
						) AS o_O
					ORDER BY POSITION FOR XML PATH('')
				) AS Position,
				/*(
					SELECT Department + ', '
					FROM 
						(
							SELECT DISTINCT Department
							FROM
								dbo.ClientStudy b
								INNER JOIN dbo.StudyPeopleTable c ON c.ClientStudyID = b.ClientStudyID							
							WHERE a.CLientID = b.ClientID AND StudyDate BETWEEN @begindate AND @enddate
						) AS o_O
					ORDER BY Department FOR XML PATH('')
				)*/ '' AS Department,
				(
					SELECT SUM(ISNULL(SERT_COUNT, 1))
					FROM 
						dbo.ClientStudy b
						INNER JOIN dbo.ClientStudyPeople c ON c.ID_STUDY = b.ID					
						/*INNER JOIN @TBL ON POS_ID = d.StudentPositionID*/
					WHERE a.CLientID = b.ID_CLIENT AND DATE BETWEEN @begindate AND @enddate
						AND ID_SERT_TYPE = '2C634734-2B27-E311-8929-000C2933B2FD'
						AND STATUS = 1
						/*AND Sertificat NOT LIKE '%[^0-9 +-]%'*/
				) AS Sertificat,
				(
					SELECT SUM(ISNULL(SERT_COUNT, 1))
					FROM 
						dbo.ClientStudy b
						INNER JOIN dbo.ClientStudyPeople c ON c.ID_STUDY = b.ID					
						/*INNER JOIN @TBL ON POS_ID = d.StudentPositionID*/
					WHERE a.CLientID = b.ID_CLIENT AND DATE BETWEEN @begindate AND @enddate
						AND ID_SERT_TYPE = 'DB1F583A-2B27-E311-8929-000C2933B2FD'
						AND STATUS = 1
				) AS TeacherSertificat,
				(
					SELECT SUM(ISNULL(SERT_COUNT, 1))
					FROM 
						dbo.ClientStudy b
						INNER JOIN dbo.ClientStudyPeople c ON c.ID_STUDY = b.ID					
						/*INNER JOIN @TBL ON POS_ID = d.StudentPositionID*/
					WHERE a.CLientID = b.ID_CLIENT AND DATE BETWEEN @begindate AND @enddate
						AND ID_SERT_TYPE = 'DC1F583A-2B27-E311-8929-000C2933B2FD'
						AND STATUS = 1
				) AS ProfSertificat
			FROM dbo.ClientTable a LEFT OUTER JOIN
				dbo.ServiceTable z ON a.ClientServiceID = z.ServiceID
			WHERE EXISTS
				(
					SELECT * 
					FROM dbo.ClientStudy b
					WHERE DATE BETWEEN @begindate AND @enddate AND a.ClientID = b.ID_CLIENT AND STATUS = 1
				) AND PayTypeID = 1 AND STATUS = 1

			ORDER BY ClientFullName
		END
		ELSE
		BEGIN
			SELECT a.ClientID, ClientFullName,
				REVERSE(STUFF(REVERSE(
					(
						SELECT CONVERT(VARCHAR(20), DATE, 104) + ', '
						FROM
							(
								SELECT DISTINCT DATE 
								FROM 
									dbo.ClientStudy b
									INNER JOIN dbo.ClientStudyPeople c ON b.ID = c.ID_STUDY
									INNER JOIN @TBL ON ID_RDD_POS = POS_ID
								WHERE DATE BETWEEN @begindate AND @enddate 
									AND a.ClientID = b.ID_CLIENT
									AND STATUS = 1
							) AS o_O
						ORDER BY DATE FOR XML PATH('')
					)
				), 1, 2, '')) AS BegDate,
				ISNULL((
					SELECT COUNT(DISTINCT (SURNAME + NAME + PATRON))
					FROM dbo.ClientStudy b INNER JOIN
						dbo.ClientStudyPeople d ON b.ID = d.ID_STUDY INNER JOIN
						@TBL ON POS_ID = ID_RDD_POS
					WHERE DATE BETWEEN @begindate AND @enddate AND a.ClientID = b.ID_CLIENT
						AND GR_COUNT IS NULL AND STATUS = 1
				), 0) + 
				ISNULL((
					SELECT SUM(GR_COUNT)
					FROM dbo.ClientStudy b INNER JOIN
						dbo.ClientStudyPeople d ON b.ID = d.ID_STUDY INNER JOIN
						@TBL ON POS_ID = ID_RDD_POS
					WHERE DATE BETWEEN @begindate AND @enddate AND a.ClientID = b.ID_CLIENT
						AND GR_COUNT IS NOT NULL AND STATUS = 1
				), 0) AS StudentCount,
				dbo.GET_TEACHER_LIST(@begindate, @enddate, a.ClientID) AS TeacherName,
				dbo.GET_STUDENT_LIST_EX(@begindate, @enddate, a.ClientID, @teacher, @student) AS StudentName,
				dbo.GET_RECOMEND_LIST(@begindate, @enddate, a.ClientID) AS Recomend,
				ServiceName,
				(
					SELECT POSITION + ', '
					FROM 
						(
							SELECT DISTINCT POSITION
							FROM
								dbo.ClientStudy b
								INNER JOIN dbo.ClientStudyPeople c ON c.ID_STUDY = b.ID							
								INNER JOIN @TBL ON ID_RDD_POS = POS_ID
							WHERE a.CLientID = b.ID_CLIENT AND DATE BETWEEN @begindate AND @enddate AND POSITION <> '' AND STATUS = 1
						) AS o_O
					ORDER BY POSITION FOR XML PATH('')
				) AS Position,
				/*(
					SELECT Department + ', '
					FROM 
						(
							SELECT DISTINCT Department
							FROM
								dbo.ClientStudy b
								INNER JOIN dbo.StudyPeopleTable c ON c.ClientStudyID = b.ClientStudyID							
								INNER JOIN @TBL ON c.StudentPositionID = POS_ID
							WHERE a.CLientID = b.ClientID AND StudyDate BETWEEN @begindate AND @enddate
						) AS o_O
					ORDER BY Department FOR XML PATH('')
				)*/ '' AS Department,
				(
					SELECT SUM(ISNULL(SERT_COUNT, 1))
					FROM 
						dbo.ClientStudy b
						INNER JOIN dbo.ClientStudyPeople c ON c.ID_STUDY = b.ID					
						INNER JOIN @TBL ON POS_ID = ID_RDD_POS
					WHERE a.CLientID = b.ID_CLIENT AND DATE BETWEEN @begindate AND @enddate
						AND ID_SERT_TYPE = '2C634734-2B27-E311-8929-000C2933B2FD'
						AND STATUS = 1
						/*AND Sertificat NOT LIKE '%[^0-9 +-]%'*/
				) AS Sertificat,
				(
					SELECT SUM(ISNULL(SERT_COUNT, 1))
					FROM 
						dbo.ClientStudy b
						INNER JOIN dbo.ClientStudyPeople c ON c.ID_STUDY = b.ID					
						INNER JOIN @TBL ON POS_ID = ID_RDD_POS
					WHERE a.CLientID = b.ID_CLIENT AND DATE BETWEEN @begindate AND @enddate
						AND ID_SERT_TYPE = 'DB1F583A-2B27-E311-8929-000C2933B2FD'
						AND STATUS = 1
						/*AND Sertificat NOT LIKE '%[^0-9 +-]%'*/
				) AS TeacherSertificat,
				(
					SELECT SUM(ISNULL(SERT_COUNT, 1))
					FROM 
						dbo.ClientStudy b
						INNER JOIN dbo.ClientStudyPeople c ON c.ID_STUDY = b.ID					
						INNER JOIN @TBL ON POS_ID = ID_RDD_POS
					WHERE a.CLientID = b.ID_CLIENT AND DATE BETWEEN @begindate AND @enddate
						AND ID_SERT_TYPE = 'DC1F583A-2B27-E311-8929-000C2933B2FD'
						AND STATUS = 1
						/*AND Sertificat NOT LIKE '%[^0-9 +-]%'*/
				) AS ProfSertificat
			FROM dbo.ClientTable a LEFT OUTER JOIN
				dbo.ServiceTable z ON a.ClientServiceID = z.ServiceID
			WHERE EXISTS
				(
					SELECT * 
					FROM dbo.ClientStudy b INNER JOIN
						dbo.ClientStudyPeople z ON z.ID_STUDY = b.ID
					WHERE DATE BETWEEN @begindate AND @enddate 
						AND a.ClientID = b.ID_CLIENT AND STATUS = 1
				) AND PayTypeID = 1 AND STATUS = 1

			ORDER BY ClientFullName
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END