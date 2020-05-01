USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_QUEST_SELECT]
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

		SELECT
			ClientQuestionID, ClientQuestionDate, QuestionName, AnswerName, ClientQuestionComment,
			CONVERT(VARCHAR(50), ClientQuestionCreateDate, 104) + ' ' + CONVERT(VARCHAR(50), ClientQuestionCreateDate, 114) + ' / ' + ClientQuestionCreateUser AS ClientQuestionCreate,
			CONVERT(VARCHAR(50), ClientQuestionLastUpdate, 104) + '  ' + CONVERT(VARCHAR(50), ClientQuestionLastUpdate, 114) + ' / ' + ClientQuestionLastUpdateUser AS ClientQuestionLastUpdate
		FROM
			dbo.ClientQuestionTable a
			INNER JOIN dbo.QuestionTable b ON a.QuestionID = b.QuestionID
			INNER JOIN dbo.AnswerTable c ON c.AnswerID = a.AnswerID
		WHERE ClientID = @CLIENT

		UNION ALL

		SELECT
			ClientQuestionID, ClientQuestionDate, QuestionName, ClientQuestionText, ClientQuestionComment,
			CONVERT(VARCHAR(50), ClientQuestionCreateDate, 104) + ' ' + CONVERT(VARCHAR(50), ClientQuestionCreateDate, 114) + ' / ' + ClientQuestionCreateUser AS ClientQuestionCreate,
			CONVERT(VARCHAR(50), ClientQuestionLastUpdate, 104) + '  ' + CONVERT(VARCHAR(50), ClientQuestionLastUpdate, 114) + ' / ' + ClientQuestionLastUpdateUser AS ClientQuestionLastUpdate
		FROM
			dbo.ClientQuestionTable a
			INNER JOIN dbo.QuestionTable b ON a.QuestionID = b.QuestionID
		WHERE ClientID = @CLIENT AND AnswerID IS NULL

		ORDER BY ClientQuestionDate DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_QUEST_SELECT] TO rl_client_question_r;
GO