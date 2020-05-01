USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_MANAGER_SELECT]
	@CLIENT	INT
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
			a.ID,
			CONVERT(VARCHAR(20), DATE, 104) + CASE WHEN TIME IS NOT NULL THEN ' ' + CONVERT(VARCHAR(20), TIME, 108) ELSE '' END AS DATE_TIME,
			SENDER, SHORT, CASE SHORT WHEN '' THEN '' ELSE SHORT + CHAR(10) END + NOTE AS NOTE, EXEC_DATE, EXEC_NOTE
		FROM
			Task.Tasks a
			INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
		WHERE SENDER <> 'Автомат'
			AND STATUS = 1
			--AND ID_CLIENT IS NOT NULL
			AND ID_CLIENT = @CLIENT
		ORDER BY DATE DESC, TIME DESC, ID DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_MANAGER_SELECT] TO rl_task_r;
GO