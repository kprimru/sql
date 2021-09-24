USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_SERVICE_REPORT_NEW]
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

		SELECT ServiceFullName,
		   (
			 SELECT COUNT(DISTINCT b.ClientID)
			 FROM dbo.ClientTable b INNER JOIN
				  dbo.ServiceTable c ON b.ClientServiceID = c.ServiceID INNER JOIN
				  dbo.ClientStudy d ON d.ID_CLIENT = b.ClientID INNER JOIN
				  dbo.ClientStudyPeople e ON e.ID_STUDY = d.ID INNER JOIN
				  dbo.TeacherTable f ON f.TeacherID = d.ID_TEACHER
			 WHERE /*LessonPlaceReport = 1 AND */a.ServiceID = c.ServiceID /*AND TeacherReport = 1 */AND d.DATE BETWEEN @pbegindate AND @penddate AND Teached = 1 and (StatusID = @statusid or @statusid IS NULL) AND d.STATUS = 1 AND b.STATUS = 1
				AND (ID_TEACHER IN (SELECT ID FROM dbo.TableIDFromXML(@TEACHER)) OR @TEACHER IS NULL)
		   ) AS ClientCount,
		   (
			 SELECT COUNT(ClientFullName + ';' + SURNAME + ';' + NAME + ';' + PATRON + ';' + CONVERT(VARCHAR(10), GR_NUMBER))
			 FROM dbo.ClientTable b INNER JOIN
				  dbo.ServiceTable c ON b.ClientServiceID = c.ServiceID INNER JOIN
				  dbo.ClientStudy d ON d.ID_CLIENT = b.ClientID INNER JOIN
				  dbo.ClientStudyPeople e ON e.ID_STUDY = d.ID INNER JOIN
				  dbo.TeacherTable f ON f.TeacherID = d.ID_TEACHER CROSS APPLY
				   (
						SELECT NUM AS GR_NUMBER
						FROM dbo.TableNumber(GR_COUNT)
				) AS o_O
			 WHERE /*LessonPlaceReport = 1 AND */a.ServiceID = c.ServiceID /*AND TeacherReport = 1*/ AND d.DATE BETWEEN @pbegindate AND @penddate AND Teached = 1 and (StatusID = @statusid or @statusid IS NULL) AND d.STATUS = 1 AND b.STATUS = 1
				AND (ID_TEACHER IN (SELECT ID FROM dbo.TableIDFromXML(@TEACHER)) OR @TEACHER IS NULL)
		   ) AS StudentCount,
		   (
			 SELECT dbo.GET_CLIENT_LIST_BY_STUDY_DATE_NEW(@pbegindate, @penddate, a.ServiceID, @statusid, @TEACHER)
		   ) AS ClientList
		FROM dbo.ServiceTable a
		where (ServiceID = @serviceid or @serviceid IS NULL)
		ORDER BY ServiceFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_SERVICE_REPORT_NEW] TO rl_report_client_study;
GO
