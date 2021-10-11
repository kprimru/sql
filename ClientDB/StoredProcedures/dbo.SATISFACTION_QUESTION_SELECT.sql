USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SATISFACTION_QUESTION_SELECT]
	@FILTER	VARCHAR(100) = NULL OUTPUT
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
			SQ_ID, SQ_TEXT, SQ_SINGLE, SQ_BOLD, SQ_ORDER,
			(
				SELECT COUNT(*)
				FROM dbo.SatisfactionAnswer
				WHERE SA_ID_QUESTION = SQ_ID
			) AS SQ_ANSWER
		FROM dbo.SatisfactionQuestion
		WHERE @FILTER IS NULL
			OR SQ_TEXT LIKE @FILTER
			OR SQ_ORDER LIKE @FILTER
		ORDER BY SQ_ORDER, SQ_TEXT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SATISFACTION_QUESTION_SELECT] TO rl_satisfaction_r;
GO
