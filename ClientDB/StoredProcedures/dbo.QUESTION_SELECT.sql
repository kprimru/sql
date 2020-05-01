USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[QUESTION_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT QuestionID, QuestionName, QuestionDate, QuestionFreeAnswer
		FROM dbo.QuestionTable a
		WHERE @FILTER IS NULL
			OR QuestionName LIKE @FILTER
			OR EXISTS
				(
					SELECT *
					FROM dbo.AnswerTable b
					WHERE a.QuestionID = b.QuestionID
						AND AnswerName LIKE @FILTER
				)
		ORDER BY QuestionName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[QUESTION_SELECT] TO rl_question_r;
GO