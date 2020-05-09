USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_DISCONNECT_LIST]
	@ID		UNIQUEIDENTIFIER,
	@TP		TINYINT, -- 0 - отключить, 1 - включить,
	@NOTE	NVARCHAR(MAX)
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

		UPDATE dbo.DistrDisconnect
		SET STATUS = 2
		WHERE ID_DISTR = @ID AND STATUS = 1

		IF @TP = 0
		BEGIN
			UPDATE dbo.DistrDisconnect
			SET STATUS = 2
			WHERE ID_DISTR = @ID AND STATUS = 1

			INSERT INTO dbo.DistrDisconnect(ID_DISTR, NOTE)
				VALUES(@ID, @NOTE)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_DISCONNECT_LIST] TO rl_client_distr_disconnect_list;
GO