USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_REPORT_NAMES]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_REPORT_NAMES]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_REPORT_NAMES]
	@SERVICE	INT,
	@MANAGER	INT
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

		IF @SERVICE IS NOT NULL
			SELECT ServiceFullName, ManagerFullName
			FROM
				dbo.ServiceTable a
				INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
			WHERE ServiceID = @SERVICE
		ELSE IF @MANAGER IS NOT NULL
			SELECT NULL AS ServiceFullName, ManagerFullName
			FROM dbo.ManagerTable
			WHERE ManagerID = @MANAGER
		ELSE
			SELECT NULL AS ServiceFullName, NULL AS ManagerFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_REPORT_NAMES] TO rl_service_report;
GO
