USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_QUESTION_UPDATE]
	@id INT,
	@questionid INT,
	@answerid INT,
	@text VARCHAR(150),
	@date SMALLDATETIME,
	@COMMENT	VARCHAR(MAX) = NULL
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

		UPDATE dbo.ClientQuestionTable
		SET QuestionID = @questionid,
			AnswerID = @answerid,
			ClientQuestionText = @text,
			ClientQuestionDate = @date,
			ClientQuestionComment = @COMMENT,
			ClientQuestionLastUpdate = GETDATE(),
			ClientQuestionLastUpdateUser = ORIGINAL_LOGIN()
		WHERE ClientQuestionID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_QUESTION_UPDATE] TO rl_client_question_u;
GO