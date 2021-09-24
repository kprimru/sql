USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Poll].[BLANK_QUESTION_SELECT]
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
			ID, NAME, ORD, ANS_MIN, ANS_MAX, TP,
			CASE TP
				WHEN 0 THEN 'однозначный выбор'
				WHEN 1 THEN 'многозначный выбор'
				WHEN 2 THEN 'свободное поле для ввода'
				WHEN 3 THEN 'число из диапазона'
			END AS TP_STR
		FROM Poll.Question
		WHERE ID_BLANK = @ID
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
GRANT EXECUTE ON [Poll].[BLANK_QUESTION_SELECT] TO rl_blank_r;
GO
