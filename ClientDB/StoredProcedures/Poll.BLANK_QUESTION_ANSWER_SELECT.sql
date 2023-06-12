USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Poll].[BLANK_QUESTION_ANSWER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Poll].[BLANK_QUESTION_ANSWER_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Poll].[BLANK_QUESTION_ANSWER_SELECT]
	@QUESTION	UNIQUEIDENTIFIER
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

		SELECT ID, NAME
		FROM Poll.Answer
		WHERE ID_QUESTION = @QUESTION
		ORDER BY ORD

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Poll].[BLANK_QUESTION_ANSWER_SELECT] TO rl_blank_r;
GO
