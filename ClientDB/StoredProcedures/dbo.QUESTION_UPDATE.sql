USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[QUESTION_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[QUESTION_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[QUESTION_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@DATE	SMALLDATETIME,
	@FREE	BIT
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

		UPDATE dbo.QuestionTable
		SET QuestionName = @NAME,
			QuestionDate = @DATE,
			QuestionFreeAnswer = @FREE
		WHERE QuestionID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[QUESTION_UPDATE] TO rl_question_u;
GO
