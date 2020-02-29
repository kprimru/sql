USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Task].[TASK_COMPLETE]
	@ID		UNIQUEIDENTIFIER,
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

		INSERT INTO Task.Tasks(ID_MASTER, DATE, TIME, SENDER, RECEIVER, ID_CLIENT, ID_STATUS, SHORT, NOTE, EXPIRE, EXEC_DATE, EXEC_NOTE, NOTIFY, NOTIFY_DAY, STATUS, UPD_DATE, UPD_USER)
			SELECT @ID, DATE, TIME, SENDER, RECEIVER, ID_CLIENT, ID_STATUS, SHORT, NOTE, EXPIRE, EXEC_DATE, EXEC_NOTE, NOTIFY, NOTIFY_DAY, 2, UPD_DATE, UPD_USER
			FROM Task.Tasks
			WHERE ID = @ID
			
		UPDATE Task.Tasks
		SET EXEC_DATE = GETDATE(),
			EXEC_NOTE = @NOTE,
			UPD_DATE  = GETDATE(),
			UPD_USER  = ORIGINAL_LOGIN(),
			ID_STATUS = (SELECT ID FROM Task.TaskStatus WHERE PSEDO = N'COMPLETE')
		WHERE ID = @ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
