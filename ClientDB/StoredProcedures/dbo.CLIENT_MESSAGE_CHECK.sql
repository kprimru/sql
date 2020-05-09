USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_MESSAGE_CHECK]
	@RES	TINYINT OUTPUT
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

		IF EXISTS
			(
				SELECT *
				FROM dbo.ClientMessage
				WHERE RECEIVE_USER = ORIGINAL_LOGIN()
					AND REMIND_DATE < GETDATE()
					AND RECEIVE_DATE IS NULL
					AND STATUS = 1
			)
			SET @RES = 1
		ELSE
			SET @RES = 0

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_MESSAGE_CHECK] TO public;
GRANT EXECUTE ON [dbo].[CLIENT_MESSAGE_CHECK] TO rl_client_message_r;
GO