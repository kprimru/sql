USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Study].[LESSON_THEME_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Study].[LESSON_THEME_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Study].[LESSON_THEME_SELECT]
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

		SELECT DISTINCT THEME
		FROM Study.Lesson
		WHERE STATUS = 1
		ORDER BY THEME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Study].[LESSON_THEME_SELECT] TO rl_study_personal_r;
GO
