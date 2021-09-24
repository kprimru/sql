USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_QUEST_INSERT]
	@CLIENT	INT,
	@DATE	SMALLDATETIME,
	@QUEST	INT,
	@ANS	INT,
	@TEXT	VARCHAR(150),
	@COMMENT	VARCHAR(MAX),
	@ID	INT = NULL OUTPUT
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

		INSERT INTO	dbo.ClientQuestionTable(ClientID, QuestionID, ClientQuestionDate,
						AnswerID, ClientQuestionText, ClientQuestionComment)
			VALUES(@CLIENT, @QUEST, @DATE, @ANS, @TEXT, @COMMENT)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_QUEST_INSERT] TO rl_client_question_i;
GO
