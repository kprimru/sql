USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_STATUS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_STATUS_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_STATUS_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT ServiceStatusID, ServiceStatusName, ServiceDefault, ServiceStatusReg, ServiceCode, ServiceStatusIndex
		FROM dbo.ServiceStatusTable
		WHERE @FILTER IS NULL
			OR ServiceStatusName LIKE @FILTER
		ORDER BY ServiceStatusIndex

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_STATUS_SELECT] TO rl_status_r;
GO
