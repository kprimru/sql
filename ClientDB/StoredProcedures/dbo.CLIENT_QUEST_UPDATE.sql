USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_QUEST_UPDATE]
	@ID	INT,
	@CLIENT	INT,
	@DATE	SMALLDATETIME,
	@QUEST	INT,
	@ANS	INT,
	@TEXT	VARCHAR(150),
	@COMMENT	VARCHAR(MAX)
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

		UPDATE	dbo.ClientQuestionTable
		SET	QuestionID = @QUEST,
			ClientQuestionDate = @DATE,
			AnswerID = @ANS,
			ClientQuestionText = @TEXT,
			ClientQuestionComment = @COMMENT,
			ClientQuestionLastUpdate = GETDATE(),
			ClientQuestionLastUpdateUser = ORIGINAL_LOGIN()
		WHERE ClientQuestionID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_QUEST_UPDATE] TO rl_client_question_u;
GO
