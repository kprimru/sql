USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Task].[TASK_STATUS_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME, PSEDO, INT_VAL
	FROM Task.TaskStatus
	ORDER BY INT_VAL
END
