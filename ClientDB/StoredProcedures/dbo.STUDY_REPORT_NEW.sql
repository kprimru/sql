USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_REPORT_NEW]
	@pbegindate VARCHAR(20),
	@penddate VARCHAR(20),
	@serviceid INT = null,
	@statusid INT = null,
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

		SELECT (
			   SELECT DISTINCT MIN(g.DATE)
			   FROM dbo.ClientStudy g
			   WHERE g.ID_CLIENT = b.ClientID AND
					 g.DATE <= @penddate AND
					 g.DATE >= @pbegindate AND
						g.TEACHED = 1
						AND g.STATUS = 1
			 ) AS MinStudyDate, a.ID AS ClientStudyID, CLientFullName, a.DATE AS StudyDate, e.NUM AS StudyNumber,
			 dbo.GET_TEACHER_LIST(@pbegindate, @penddate, b.CLientID) AS TeacherName,
			 (CONVERT(VARCHAR(50), e.ID) + ' ' + RTRIM(LTRIM(SURNAME)) + ' ' + RTRIM(LTRIM(NAME)) + ' ' + RTRIM(LTRIM(PATRON)) + CONVERT(VARCHAR(10), GR_NUMBER)) AS StudentFullName, ServiceName,
			 a.DATE AS StudyDateStr,
			 RIVAL
		FROM dbo.ClientStudy a INNER JOIN
		   dbo.ClientStudyPeople e ON a.ID = e.ID_STUDY INNER JOIN
		   dbo.ClientTable b ON a.ID_CLIENT = b.CLientID INNER JOIN
		   dbo.TeacherTable c ON c.TeacherID = a.ID_TEACHER INNER JOIN
		   dbo.ServiceTable d ON d.ServiceID = b.CLientServiceID CROSS APPLY
		   (
				SELECT NUM AS GR_NUMBER
				FROM dbo.TableNumber(GR_COUNT)
		   ) AS o_O

		WHERE a.DATE <= @penddate AND a.DATE >= @pbegindate /*AND TeacherReport = 1  */
			and (ServiceID = @serviceid or @serviceid IS NULL) AND Teached = 1
			and (StatusID = @statusid or @statusid IS NULL)
			AND (ID_TEACHER IN (SELECT ID FROM dbo.TableIDFromXML(@TEACHER)) OR @TEACHER IS NULL)
			AND a.STATUS = 1
			AND b.STATUS = 1
		ORDER BY MinStudyDate, ClientFullName, a.DATE, a.ID, e.NUM, e.NAME, TeacherName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[STUDY_REPORT_NEW] TO rl_report_client_study;
GO