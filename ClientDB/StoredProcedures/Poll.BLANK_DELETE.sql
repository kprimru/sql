USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Poll].[BLANK_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Poll].[BLANK_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Poll].[BLANK_DELETE]
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

		DELETE
		FROM Poll.Answer
		WHERE ID_QUESTION IN
			(
				SELECT ID
				FROM Poll.Question
				WHERE ID_BLANK = @ID
			)

		DELETE
		FROM Poll.Question
		WHERE ID_BLANK = @ID

		DELETE
		FROM Poll.Blank
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Poll].[BLANK_DELETE] TO rl_blank_d;
GO
