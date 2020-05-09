USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_QUESTION_ANSWER_FILTER]
	@questionid INT,
	@serviceid INT,
	@begin	varchar(20) = null,
	@end varchar(20) = null
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
		@DebugContext	= @DebugContext OUT;

	BEGIN TRY;

		WITH dt AS (
			SELECT 
				CASE
					WHEN b.AnswerID IS NOT NULL THEN AnswerName
					WHEN b.ClientQuestionText IS NOT NULL THEN b.ClientQuestionText
					ELSE NULL
				END AS AnswerName
			FROM
				[dbo].[ClientList@Get?Read]() INNER JOIN
				dbo.ClientTable a ON ClientID = WCL_ID INNER JOIN
				dbo.ClientQuestionTable b ON a.ClientID = b.ClientID INNER JOIN
				dbo.QuestionTable c ON c.QuestionID = b.QuestionID LEFT OUTER JOIN
				dbo.AnswerTable e ON e.AnswerID = b.AnswerID
			WHERE c.QuestionID = @questionid
				and (b.ClientQuestionDate >= @begin or @begin is null)
				and (b.ClientQuestionDate <= @end or @end is null)
		 )


		SELECT
			AnswerName, COUNT(*) AS AnswerCount,
			ROUND(CONVERT(DECIMAL(18, 10), COUNT(*) * 100)/(SELECT COUNT(*) FROM dt), 2) AS AnswerPercent
		FROM dt
		GROUP BY AnswerName
		ORDER BY AnswerName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_QUESTION_ANSWER_FILTER] TO rl_filter_question;
GO