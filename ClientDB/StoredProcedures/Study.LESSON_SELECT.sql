USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Study].[LESSON_SELECT]
	@TEACHER	NVARCHAR(128),
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TXT		NVARCHAR(256)
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

		SELECT
			ID,
			CASE WHEN RN = 1 THEN DATE ELSE NULL END AS DATE_S,
			CASE WHEN RN = 1 THEN TEACHER ELSE NULL END AS TEACHER_S, THEME, NOTE
		FROM
			(
				SELECT ID, DATE, TEACHER, THEME, NOTE, ROW_NUMBER() OVER(PARTITION BY DATE, TEACHER ORDER BY DATE DESC, TEACHER, THEME, NOTE) AS RN
				FROM Study.Lesson
				WHERE STATUS = 1
					AND (DATE >= @BEGIN OR @BEGIN IS NULL)
					AND (DATE <= @END OR @END IS NULL)
					AND (TEACHER = @TEACHER OR @TEACHER IS NULL)
					AND (THEME LIKE @TXT OR NOTE LIKE @TXT OR @TXT IS NULL)
			) AS o_O
		ORDER BY DATE DESC, TEACHER, THEME, NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Study].[LESSON_SELECT] TO rl_study_personal_r;
GO