USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Task].[TASK_HISTORY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Task].[TASK_HISTORY_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Task].[TASK_HISTORY_SELECT]
	@ID	UNIQUEIDENTIFIER
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

		SELECT
			DATE AS [Дата], LEFT(CONVERT(VARCHAR(20), TIME, 108), 5) AS [Время], b.NAME AS [Статус],
			SHORT AS [Заголовок], NOTE AS [Описание], EXPIRE AS [Выполнить до],
			EXEC_DATE AS [Дата выполнения], EXEC_NOTE AS [Описание к выполнению],
			UPD_DATE AS [Дата редакции], UPD_USER AS [Кто редактировал]
		FROM
			Task.Tasks a
			INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
		WHERE ID_MASTER = @ID OR a.ID = @ID
		ORDER BY ID_MASTER, UPD_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Task].[TASK_HISTORY_SELECT] TO rl_task_r;
GO
