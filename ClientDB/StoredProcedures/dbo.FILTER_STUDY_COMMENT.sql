USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FILTER_STUDY_COMMENT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FILTER_STUDY_COMMENT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[FILTER_STUDY_COMMENT]
	@pbegindate SMALLDATETIME,
	@penddate SMALLDATETIME,
	@pmanagerid int,
	@pserviceid int,
	@pteacherid int = NULL,
	@learned bit = null
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

		SELECT DISTINCT
			ClientFullName,	DATE AS StudyDate, TeacherName,	Need AS SystemNeed,	Teached,
			Recomend, Note AS StudyNote, ServiceName, b.CLientID
		FROM
			dbo.ClientStudy a INNER JOIN
			dbo.ClientTable b ON a.ID_CLIENT = b.ClientID INNER JOIN
			dbo.ServiceTable c ON b.ClientServiceID = c.ServiceID INNER JOIN
			dbo.TeacherTable d ON d.TeacherID = a.ID_TEACHER
		WHERE NOTE <> ''
			AND a.STATUS = 1
			AND ClientServiceID = ISNULL(@pserviceid, ClientServiceID)
			AND ManagerID = ISNULL(@pmanagerid, ManagerID)
			AND d.TeacherID = ISNULL(@pteacherid, d.TeacherID)
			AND DATE BETWEEN @pbegindate AND @penddate
			AND (Teached = @learned OR @learned IS NULL)
			AND b.STATUS = 1
		ORDER BY StudyDate DESC, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[FILTER_STUDY_COMMENT] TO rl_filter_study_comment;
GO
