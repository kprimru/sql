USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[TEST_QUESTION_ANSWER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[TEST_QUESTION_ANSWER_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[TEST_QUESTION_ANSWER_SELECT]
	@ID	UNIQUEIDENTIFIER
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

		SELECT ID, ANS_TEXT, CORRECT
		FROM Subhost.TestAnswer
		WHERE ID_QUESTION = @ID
		ORDER BY NEWID()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[TEST_QUESTION_ANSWER_SELECT] TO rl_web_subhost;
GO
