USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SATISFACTION_QUESTION_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SATISFACTION_QUESTION_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SATISFACTION_QUESTION_GET]
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

		SELECT
			SQ_ID, SQ_TEXT, SQ_SINGLE, SQ_BOLD, SQ_ORDER, SQ_ACTIVE
		FROM dbo.SatisfactionQuestion
		WHERE SQ_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SATISFACTION_QUESTION_GET] TO rl_satisfaction_r;
GO
