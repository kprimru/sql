USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_SATISFACTION_QUESTION]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_SATISFACTION_QUESTION]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_SATISFACTION_QUESTION]
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

		/*
		SELECT
			SQ_ID, SQ_TEXT, SQ_SINGLE, SQ_BOLD, SQ_ORDER, CSQ_ID, CSQ_NOTE,
			CONVERT(BIT, CASE WHEN CSQ_ID IS NULL THEN 0 ELSE 1 END) AS CSQ_CHECKED
		FROM
			dbo.SatisfactionQuestion
			LEFT OUTER JOIN dbo.ClientSatisfactionQuestion ON CSQ_ID_QUESTION = SQ_ID
			LEFT OUTER JOIN dbo.ClientSatisfaction ON CS_ID = CSQ_ID_CS
			LEFT OUTER JOIN dbo.ClientCall ON CC_ID = CS_ID_CALL AND CC_ID = @ID
		ORDER BY SQ_ORDER
		*/

		SELECT
			SQ_ID, SQ_TEXT, SQ_SINGLE, SQ_BOLD, SQ_ORDER, CSQ_ID, CSQ_NOTE,
			CONVERT(BIT, CASE WHEN CSQ_ID IS NULL THEN 0 ELSE 1 END) AS CSQ_CHECKED
		FROM
			dbo.SatisfactionQuestion
			LEFT OUTER JOIN
			(
				SELECT CSQ_ID, CSQ_NOTE, CSQ_ID_QUESTION
				FROM
					dbo.ClientSatisfactionQuestion
					INNER JOIN dbo.ClientSatisfaction ON CS_ID = CSQ_ID_CS
					INNER JOIN dbo.ClientCall ON CC_ID = CS_ID_CALL
				WHERE CC_ID = @ID
			) AS o_O ON CSQ_ID_QUESTION = SQ_ID
		ORDER BY SQ_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SATISFACTION_QUESTION] TO rl_client_call_r;
GO
