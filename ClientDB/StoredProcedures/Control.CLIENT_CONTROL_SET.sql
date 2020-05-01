USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Control].[CLIENT_CONTROL_SET]
	@CLIENT		INT,
	@NOTE		NVARCHAR(MAX),
	@NOTIFY		SMALLDATETIME,
	@ID_GROUP	UNIQUEIDENTIFIER,
	@RECEIVER	NVARCHAR(128),
	@REM_GROUP	BIT,
	@REM_AUTHOR	BIT,
	@ID			UNIQUEIDENTIFIER
WITH EXECUTE AS OWNER
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

		DECLARE @PSEDO NVARCHAR(64)
		SELECT @PSEDO = PSEDO FROM Control.ControlGroup WHERE ID = @ID_GROUP

		IF @ID IS NULL
			INSERT INTO Control.ClientControl(ID_CLIENT, DATE, AUTHOR, NOTE, NOTIFY, ID_GROUP, RECEIVER, REMOVE_GROUP, REMOVE_AUTHOR)
				SELECT @CLIENT, GETDATE(), ORIGINAL_LOGIN(), @NOTE, @NOTIFY, @ID_GROUP, @RECEIVER, @REM_GROUP, @REM_AUTHOR
		ELSE
			UPDATE Control.ClientControl
			SET NOTE = @NOTE,
				NOTIFY = @NOTIFY,
				ID_GROUP = @ID_GROUP,
				RECEIVER = @RECEIVER,
				REMOVE_GROUP = @REM_GROUP,
				REMOVE_AUTHOR = @REM_AUTHOR
			WHERE ID = @ID

		IF @ID_GROUP IS NOT NULL
		BEGIN
			INSERT INTO dbo.ClientMessage(ID_CLIENT, TP, DATE, NOTE, RECEIVE_USER, HARD_READ)
				SELECT DISTINCT @CLIENT, 1, GETDATE(), 'Клиент был поставлен на контроль с описанием: ' + @NOTE, US_NAME, 0
				FROM Security.RoleUserView
				WHERE
					(RL_NAME = 'rl_control_law' AND @PSEDO = 'LAW')
					OR
					(RL_NAME = 'rl_control_manager' AND @PSEDO = 'MANAGER' AND US_NAME IN (SELECT ManagerLogin FROM dbo.ClientView WITH(NOEXPAND) WHERE ClientID = @CLIENT))
					OR
					(RL_NAME = 'rl_control_duty' AND @PSEDO = 'DUTY')
					OR
					(RL_NAME = 'rl_control_audit' AND @PSEDO = 'AUDIT')
					OR
					(RL_NAME = 'rl_control_chief' AND @PSEDO = 'CHIEF')
					OR
					(RL_NAME = 'rl_control_teacher' AND @PSEDO = 'TEACHER')
		END
		ELSE
		BEGIN
			INSERT INTO dbo.ClientMessage(ID_CLIENT, TP, DATE, NOTE, RECEIVE_USER, HARD_READ)
				SELECT @CLIENT, 1, GETDATE(), 'Клиент был поставлен на контроль с описанием: ' + @NOTE, @RECEIVER, 0
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Control].[CLIENT_CONTROL_SET] TO rl_control_u;
GO