USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[PERSONAL_TEST_QUESTION_SELECT]
	@TEST	UNIQUEIDENTIFIER
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
			a.ID, b.ID AS QST_ID, b.QST_TEXT, b.TP, a.STATUS,
			CASE
				b.TP WHEN 1 THEN a.ANS
				ELSE
					(
						SELECT '{' + CONVERT(NVARCHAR(64), ID_ANSWER) + '}' AS '@id'
						FROM Subhost.PersonalTestAnswer z
						WHERE z.ID_QUESTION = a.ID
						ORDER BY ID_ANSWER FOR XML PATH('item'), ROOT('root')
					)
			END AS ANS,
			c.NOTE AS CHECK_NOTE, c.RESULT
		FROM
			Subhost.PersonalTestQuestion a
			INNER JOIN Subhost.TestQuestion b ON a.ID_QUESTION = b.ID
			LEFT OUTER JOIN Subhost.CheckTestQuestion c ON c.ID_QUESTION = a.ID
		WHERE a.ID_TEST = @TEST
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
GRANT EXECUTE ON [Subhost].[PERSONAL_TEST_QUESTION_SELECT] TO rl_web_subhost;
GO
