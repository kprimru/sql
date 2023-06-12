USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_STATE_CLEAR]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_STATE_CLEAR]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_STATE_CLEAR]
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

		DELETE
		FROM dbo.ServiceStateDetail
		WHERE ID_STATE IN
			(
				SELECT ID
				FROM dbo.ServiceState
				WHERE STATUS <> 1
					AND DATE <= DATEADD(MONTH, -1, GETDATE())
			)

		DELETE
		FROM dbo.ServiceState
		WHERE STATUS <> 1
			AND DATE <= DATEADD(MONTH, -1, GETDATE())

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_STATE_CLEAR] TO rl_service_state_u;
GO
