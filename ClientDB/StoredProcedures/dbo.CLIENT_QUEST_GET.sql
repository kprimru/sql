﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_QUEST_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_QUEST_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_QUEST_GET]
	@ID	INT
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
			ClientQuestionDate, QuestionID, AnswerID, ClientQuestionText, ClientQuestionComment
		FROM
			dbo.ClientQuestionTable a
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
GRANT EXECUTE ON [dbo].[CLIENT_QUEST_GET] TO rl_client_question_r;
GO
