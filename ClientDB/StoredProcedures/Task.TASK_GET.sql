USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Task].[TASK_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DATE, TIME, RECEIVER, ID_CLIENT, SHORT, NOTE, EXPIRE, SENDER, NOTIFY, NOTIFY_DAY
	FROM Task.Tasks
	WHERE ID = @ID
END
