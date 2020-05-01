USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_MESSAGE_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SENDER		NVARCHAR(128),
	@RECEIVE	NVARCHAR(128),
	@TEXT		NVARCHAR(512),
	@RC			INT = NULL OUTPUT
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

		SET @END = DATEADD(DAY, 1, @END)

		SELECT
			ID, DATE, ClientID, ClientFullName,
			SENDER, NOTE, RECEIVE_USER, RECEIVE_DATE
		FROM
			dbo.ClientMessage
			LEFT OUTER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = ID_CLIENT
		WHERE STATUS = 1
			AND HARD_READ = 1
			AND (DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE < @END OR @END IS NULL)
			AND (SENDER = @SENDER OR @SENDER IS NULL)
			AND (RECEIVE_USER = @RECEIVE OR @RECEIVE IS NULL)
			AND (NOTE LIKE @TEXT OR @TEXT IS NULL)
		ORDER BY DATE DESC, ClientFullName, RECEIVE_USER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_MESSAGE_FILTER] TO rl_client_message_filter;
GO