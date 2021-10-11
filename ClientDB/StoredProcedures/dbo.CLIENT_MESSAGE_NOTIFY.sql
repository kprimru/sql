USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_MESSAGE_NOTIFY]
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

		SELECT TOP 30
			ID, ClientFullName, ID_CLIENT,
			ClientFullName + ' ' + CONVERT(VARCHAR(20), DATE, 104) + ' ' + NOTE AS NOTE
		FROM
			dbo.ClientMessage a
			INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
		WHERE RECEIVE_USER = ORIGINAL_LOGIN()
			AND a.STATUS = 1
			AND HIDE = 0
		ORDER BY UPD_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_MESSAGE_NOTIFY] TO rl_client_message_r;
GO
