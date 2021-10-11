USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_SATISFACTION_ANSWER]
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

		SELECT SA_ID, SA_ID_QUESTION, SA_TEXT, CSA_ID, CONVERT(BIT, CASE WHEN CSA_ID IS NULL THEN 0 ELSE 1 END) AS CSA_CHECKED
		FROM
			dbo.SatisfactionAnswer
			INNER JOIN dbo.SatisfactionQuestion ON SQ_ID = SA_ID_QUESTION
			LEFT OUTER JOIN
				(
					SELECT CSA_ID, CSA_ID_ANSWER, CSQ_ID_QUESTION
					FROM
						dbo.ClientCall
						LEFT OUTER JOIN dbo.ClientSatisfaction ON CC_ID = CS_ID_CALL
						LEFT OUTER JOIN dbo.ClientSatisfactionQuestion ON CSQ_ID_CS = CS_ID
						LEFT OUTER JOIN dbo.ClientSatisfactionAnswer ON CSQ_ID = CSA_ID_QUESTION
					WHERE CC_ID = @ID
				) AS o_O ON CSA_ID_ANSWER = SA_ID AND CSQ_ID_QUESTION = SQ_ID
		ORDER BY SQ_ORDER, SA_ORDER, SA_TEXT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SATISFACTION_ANSWER] TO rl_client_call_r;
GO
