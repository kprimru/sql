USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Poll].[POLL_ANSWER_SELECT]
	@ID_ANSWER	UNIQUEIDENTIFIER,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@ID_QUEST	UNIQUEIDENTIFIER = NULL,
	@TXT		NVARCHAR(512) = NULL
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

		IF @ID_ANSWER IS NOT NULL
			SELECT x.ID, ClientFullName, ClientID, ServiceName, ManagerName, x.DATE
			FROM
				Poll.ClientPollQuestion z
				INNER JOIN Poll.ClientPollAnswer y ON y.ID_QUESTION = z.ID
				INNER JOIN Poll.ClientPoll x ON x.ID = z.ID_POLL
				INNER JOIN dbo.ClientView t WITH(NOEXPAND) ON t.ClientID = x.ID_CLIENT
			WHERE y.ID_ANSWER = @ID_ANSWER
				AND (DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (DATE <= @END OR @END IS NULL)
			ORDER BY ClientFullName, x.DATE DESC
		ELSE
			SELECT x.ID, ClientFullName, ClientID, ServiceName, ManagerName, x.DATE
			FROM
				Poll.ClientPollQuestion z
				INNER JOIN Poll.ClientPollAnswer y ON y.ID_QUESTION = z.ID
				INNER JOIN Poll.ClientPoll x ON x.ID = z.ID_POLL
				INNER JOIN dbo.ClientView t WITH(NOEXPAND) ON t.ClientID = x.ID_CLIENT
			WHERE z.ID_QUESTION = @ID_QUEST
				AND y.TEXT_ANSWER = @TXT
				AND (DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (DATE <= @END OR @END IS NULL)
			ORDER BY ClientFullName, x.DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Poll].[POLL_ANSWER_SELECT] TO rl_blank_report;
GO
