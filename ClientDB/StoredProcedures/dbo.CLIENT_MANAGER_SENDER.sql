USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_MANAGER_SENDER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_MANAGER_SENDER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_MANAGER_SENDER]
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

		SELECT DISTINCT SENDER
		FROM Task.Tasks
		WHERE STATUS = 1 AND ID_CLIENT IS NOT NULL

		UNION

		SELECT DISTINCT PERSONAL
		FROM dbo.ClientContact
		WHERE STATUS = 1

		ORDER BY SENDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_MANAGER_SENDER] TO rl_manager_filter;
GRANT EXECUTE ON [dbo].[CLIENT_MANAGER_SENDER] TO rl_task_all;
GO
