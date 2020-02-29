USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STUDY_TEACHER_REPORT_NEW]
  @pbegindate SMALLDATETIME,
  @penddate SMALLDATETIME,
  @serviceid int = null,
  @statusid int = null,
  @TEACHER	NVARCHAR(MAX) = NULL
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

		IF OBJECT_ID('tempdb..#student') IS NOT NULL
			DROP TABLE #student

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		SELECT DISTINCT (Convert(varchar(50), d.ID) + d.SURNAME + 
					   d.NAME + d.PATRON + CONVERT(VARCHAR(10), GR_NUMBER)) AS StudentAllName, ID_TEACHER AS TeacherID    
		INTO #student
			FROM 
				dbo.ClientStudy a 
				INNER JOIN dbo.ClientStudyPeople d ON a.ID = d.ID_STUDY 
				INNER JOIN dbo.ClientTable z ON z.ClientID = a.ID_CLIENT
				CROSS APPLY
					(
						SELECT NUM AS GR_NUMBER
						FROM dbo.TableNumber(GR_COUNT)
					) AS o_O
			WHERE DATE <= @penddate 
				AND DATE >= @pbegindate  
				AND a.STATUS = 1 
				AND z.STATUS = 1 
				AND (ID_TEACHER IN (SELECT ID FROM dbo.TableIDFromXML(@TEACHER)) OR @TEACHER IS NULL)
				AND (ClientServiceID = @serviceid or @serviceid is null) 
				AND Teached = 1
				AND (StatusID = @statusid OR @statusid IS NULL)

	  SELECT DISTINCT a.ID_CLIENT AS ClientID, ID_TEACHER AS TeacherID/*
					  (
						SELECT TOP 1 b.ID_TEACHER 
						FROM dbo.ClientStudy b INNER JOIN  
							 dbo.TeacherTable c ON b.ID_TEACHER = c.TeacherID INNER JOIN
							 dbo.ClientStudyPeople d ON d.ID_STUDY = b.ID
						WHERE DATE <= @penddate AND DATE >= @pbegindate  AND
							  b.ID_CLIENT = a.ID_CLIENT AND Teached = 1 AND b.STATUS = 1
							  AND (ID_TEACHER = @TEACHER OR @TEACHER IS NULL)
						ORDER BY TeacherName DESC
					  ) AS TeacherID*/
	  INTO #client
	  FROM dbo.ClientStudy a INNER JOIN
		   dbo.ClientStudyPeople e ON e.ID_STUDY = a.ID INNER JOIN
			dbo.ClientTable z ON z.ClientID = a.ID_CLIENT
	  WHERE DATE <= @penddate AND DATE >= @pbegindate  AND 
			(ClientServiceID = @serviceid or @serviceid is null) AND Teached = 1		
			and (StatusID = @statusid or @statusid IS NULL)
			AND (ID_TEACHER IN (SELECT ID FROM dbo.TableIDFromXML(@TEACHER)) OR @TEACHER IS NULL)
			AND a.STATUS = 1 AND z.STATUS = 1



	  SELECT TeacherName, 
			 (
				SELECT COUNT(DISTINCT b.ID)
				FROM 
					dbo.ClientStudy b 
					INNER JOIN dbo.ClientStudyPeople c ON b.ID = c.ID_STUDY 
					INNER JOIN dbo.ClientTable z ON z.ClientID = b.ID_CLIENT
				WHERE DATE <= @penddate AND DATE >= @pbegindate 
					AND ID_TEACHER = a.TeacherID                
					AND  (ClientServiceID = @serviceid or @serviceid is null) AND Teached = 1 AND b.STATUS = 1 AND z.STATUS = 1
			and (StatusID = @statusid or @statusid IS NULL)
		
			 ) AS LessonCount,
			 (
			   SELECT COUNT(b.StudentAllName)
			   FROM #student b
			   WHERE b.TeacherID = a.TeacherID 
			 ) AS StudentCount,
			 (
			   SELECT COUNT(DISTINCT ClientID)
			   FROM #client b
			   WHERE b.TeacherID = a.TeacherID           
			 ) AS ClientCount ,
			 (
				SELECT COUNT(*)
				FROM 
					dbo.ClientStudyClaimWork z
					INNER JOIN dbo.ClientStudyClaim y ON z.ID_CLAIM = y.ID
					INNER JOIN dbo.ClientTable x ON y.ID_CLIENT = x.ClientID
				WHERE z.STATUS = 1
					AND dbo.DateOf(z.DATE) BETWEEN @pbegindate AND @penddate
					AND z.TEACHER = TeacherLogin
					AND TP = 1
					AND x.STATUS = 1
					AND (x.ClientServiceID = @SERVICEID OR @SERVICEID IS NULL)
			 ) AS VisitCount,
			 (
				SELECT COUNT(*)
				FROM dbo.ClientStudyVisit z
				WHERE z.ID_TEACHER = a.TeacherID
					AND z.DATE BETWEEN @pbegindate AND @penddate
					AND z.STATUS = 1
			 ) AS VISIT_SERVICE
	  FROM dbo.TeacherTable a  
	  WHERE (TeacherID IN (SELECT ID FROM dbo.TableIDFromXML(@TEACHER)) OR @TEACHER IS NULL)
	  ORDER BY TeacherName

	  DROP TABLE #student
	  DROP TABLE #client

	EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END