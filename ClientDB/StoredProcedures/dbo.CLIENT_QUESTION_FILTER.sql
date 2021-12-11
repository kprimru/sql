USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_QUESTION_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_QUESTION_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_QUESTION_FILTER]
	@questionid INT,
	@serviceid INT,
	@begin smalldatetime = null,
	@end   smalldatetime = null
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
			ClientFullName, ClientQuestionDate, ClientQuestionComment,
			CASE
				WHEN b.AnswerID IS NOT NULL THEN AnswerName
				WHEN b.ClientQuestionText IS NOT NULL THEN b.ClientQuestionText
				ELSE NULL
			END AS AnswerName, ServiceName
		FROM
			[dbo].[ClientList@Get?Read]() INNER JOIN
			dbo.ClientTable a ON WCL_ID = ClientID INNER JOIN
			dbo.ClientQuestionTable b ON a.ClientID = b.ClientID INNER JOIN
			dbo.QuestionTable c ON c.QuestionID = b.QuestionID INNER JOIN
			dbo.ServiceTable d ON d.ServiceID = a.ClientServiceID LEFT OUTER JOIN
			dbo.AnswerTable e ON e.AnswerID = b.AnswerID
		WHERE (ServiceID = @serviceid OR @serviceid IS NULL)
			AND (c.QuestionID = @questionid OR @questionid IS NULL)
			AND (b.CLientQuestionDate >= @begin or @begin IS NULL)
			AND (b.CLientQuestionDate <= @end or @end IS NULL)
		ORDER BY ClientFullName, QuestionName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_QUESTION_FILTER] TO rl_filter_question;
GO
