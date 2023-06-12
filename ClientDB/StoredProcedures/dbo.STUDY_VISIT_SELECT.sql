USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_VISIT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_VISIT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STUDY_VISIT_SELECT]
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

		SELECT ID, ID_TEACHER, TeacherName, DATE, NOTE
		FROM
			dbo.ClientStudyVisit a
			INNER JOIN dbo.TeacherTable b ON a.ID_TEACHER = TeacherID
		WHERE a.STATUS = 1
			AND ID_CLIENT = @CLIENT
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_VISIT_SELECT] TO rl_client_study_r;
GO
