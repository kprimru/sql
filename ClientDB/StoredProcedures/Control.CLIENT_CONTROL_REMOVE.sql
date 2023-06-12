USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Control].[CLIENT_CONTROL_REMOVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Control].[CLIENT_CONTROL_REMOVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Control].[CLIENT_CONTROL_REMOVE]
	@ID	UNIQUEIDENTIFIER,
	@NOTE	NVARCHAR(MAX) = NULL
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

		UPDATE Control.ClientControl
		SET REMOVE_DATE	=	GETDATE(),
			REMOVE_USER	=	ORIGINAL_LOGIN(),
			REMOVE_NOTE =	@NOTE
		WHERE ID = @ID

		IF @@ROWCOUNT <> 0
		BEGIN
			INSERT INTO dbo.ClientMessage(ID_CLIENT, TP, DATE, NOTE, RECEIVE_USER, HARD_READ)
				SELECT ID_CLIENT, 1, GETDATE(), 'Клиент был снят с контроля', AUTHOR, 0
				FROM Control.ClientControl
				WHERE ID = @ID
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
GRANT EXECUTE ON [Control].[CLIENT_CONTROL_REMOVE] TO rl_control_teacher;
GRANT EXECUTE ON [Control].[CLIENT_CONTROL_REMOVE] TO rl_control_u;
GO
