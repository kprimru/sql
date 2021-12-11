USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_QUESTION_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_QUESTION_ADD]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_QUESTION_ADD]
	@clientid INT,
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

		INSERT INTO dbo.ClientQuestionTable(
					ClientID, QuestionID, AnswerID,
					ClientQuestionText, ClientQuestionDate,
					ClientQuestionComment,
					ClientQuestionLastUpdate, ClientQuestionLastUpdateUser)
		VALUES (@clientid, @questionid, @answerid, @text, @date, @COMMENT, GETDATE(), ORIGINAL_LOGIN())

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_QUESTION_ADD] TO rl_client_question_i;
GO
