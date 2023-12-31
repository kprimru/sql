USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_MESSAGE_SELECT]
	@CLIENT	INT
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

		SELECT DISTINCT SENDER, DATE, NOTE,
			REVERSE(STUFF(REVERSE(
				(
					SELECT
						RECEIVE_USER +
						ISNULL(' ' +
							CONVERT(VARCHAR(20), RECEIVE_DATE, 104) + ' ' +
							CONVERT(VARCHAR(20), RECEIVE_DATE, 108)
							, '') +
						ISNULL(' ' + RECEIVE_HOST, '') + ', '
					FROM dbo.ClientMessage b
					WHERE a.SENDER = b.SENDER AND a.DATE = b.DATE AND a.NOTE = b.NOTE AND b.STATUS = 1
					ORDER BY TP, RECEIVE_USER FOR XML PATH('')
				)
			), 1, 2, '')) AS RECEIVE_DATA
		FROM dbo.ClientMessage a
		WHERE ID_CLIENT = @CLIENT AND STATUS = 1
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_MESSAGE_SELECT] TO rl_client_message_r;
GO
