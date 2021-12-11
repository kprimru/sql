USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[QUESTION_ANSWER_SET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[QUESTION_ANSWER_SET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[QUESTION_ANSWER_SET]
	@ID		INT,
	@QUEST	INT,
	@NAME	VARCHAR(150)
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

		IF @ID IS NOT NULL
			UPDATE dbo.AnswerTable
			SET AnswerName = @NAME
			WHERE AnswerID = @ID
		ELSE
			INSERT INTO dbo.AnswerTable(QuestionID, AnswerName)
				VALUES(@QUEST, @NAME)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[QUESTION_ANSWER_SET] TO rl_question_u;
GO
