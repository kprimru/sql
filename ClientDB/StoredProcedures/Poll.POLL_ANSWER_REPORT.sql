USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Poll].[POLL_ANSWER_REPORT]
	@ANS	NVARCHAR(MAX),
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
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
			ClientFullName, ServiceName, x.DATE, w.CC_PERSONAL, x.NOTE, q.NAME AS QST_NAME, p.NAME AS ANS_NAME
		FROM
			Poll.ClientPollQuestion z
			INNER JOIN Poll.ClientPollAnswer y ON y.ID_QUESTION = z.ID
			INNER JOIN Poll.ClientPoll x ON x.ID = z.ID_POLL
			INNER JOIN dbo.ClientView t WITH(NOEXPAND) ON t.ClientID = x.ID_CLIENT
			INNER JOIN dbo.TableGUIDFromXML(@ANS) u ON u.ID = y.ID_ANSWER
			INNER JOIN Poll.Answer p ON p.ID = y.ID_ANSWER
			INNER JOIN Poll.Question q ON q.ID = z.ID_QUESTION
			LEFT OUTER JOIN dbo.ClientCall w ON w.CC_ID = x.ID_CALL
		WHERE (DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE <= @END OR @END IS NULL)
		ORDER BY ServiceName, ClientFullName, q.ORD, p.ORD

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Poll].[POLL_ANSWER_REPORT] TO rl_blank_report;
GO
