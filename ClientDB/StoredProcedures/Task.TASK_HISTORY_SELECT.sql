USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
			DATE AS [����], LEFT(CONVERT(VARCHAR(20), TIME, 108), 5) AS [�����], b.NAME AS [������],
			SHORT AS [���������], NOTE AS [��������], EXPIRE AS [��������� ��],
			EXEC_DATE AS [���� ����������], EXEC_NOTE AS [�������� � ����������],
			UPD_DATE AS [���� ��������], UPD_USER AS [��� ������������]
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
GRANT EXECUTE ON [Task].[TASK_HISTORY_SELECT] TO rl_task_r;
GO