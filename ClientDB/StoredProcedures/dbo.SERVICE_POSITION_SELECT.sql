USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_POSITION_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_POSITION_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_POSITION_SELECT]
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

		SELECT ServicePositionID, ServicePositionName
		FROM dbo.ServicePositionTable
		WHERE @FILTER IS NULL
			OR ServicePositionName LIKE @FILTER
		ORDER BY ServicePositionName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_POSITION_SELECT] TO rl_service_position_r;
GO
