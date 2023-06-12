USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DISCONNECT_REASON_CHANGE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DISCONNECT_REASON_CHANGE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DISCONNECT_REASON_CHANGE]
	@ID		UNIQUEIDENTIFIER,
	@REASON	UNIQUEIDENTIFIER,
	@NOTE	VARCHAR(MAX),
	@DATE	SMALLDATETIME
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

		UPDATE dbo.ClientDisconnect
		SET CD_ID_REASON	=	@REASON,
			CD_NOTE			=	@NOTE,
			CD_DATE			=	@DATE
		WHERE CD_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISCONNECT_REASON_CHANGE] TO rl_client_disconnect;
GO
