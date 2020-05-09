USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GET_SERVICE_FULL_NAME]
	@serviceid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT ServiceFullName, ManagerName
		FROM
			dbo.ServiceTable a LEFT OUTER JOIN
			dbo.ManagerTable b ON a.ManagerID = b.ManagerID
		WHERE ServiceID = @serviceid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_SERVICE_FULL_NAME] TO rl_report_graf_common;
GRANT EXECUTE ON [dbo].[GET_SERVICE_FULL_NAME] TO rl_report_graf_time;
GRANT EXECUTE ON [dbo].[GET_SERVICE_FULL_NAME] TO rl_report_graf_update;
GRANT EXECUTE ON [dbo].[GET_SERVICE_FULL_NAME] TO rl_report_service_graf;
GRANT EXECUTE ON [dbo].[GET_SERVICE_FULL_NAME] TO rl_service_report;
GO