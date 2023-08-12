USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[_QUESTION_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[_QUESTION_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[_QUESTION_SELECT]
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
			QuestionID, QuestionName,
			Convert(VARCHAR(20), CONVERT(DATETIME, QuestionDate, 112), 104) AS QuestionDateStr, QuestionFreeAnswer
		FROM dbo.QuestionTable
		ORDER BY QuestionDate DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[_QUESTION_SELECT] TO public;
GO
