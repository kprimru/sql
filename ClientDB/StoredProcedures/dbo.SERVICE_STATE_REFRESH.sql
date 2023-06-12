USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_STATE_REFRESH]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_STATE_REFRESH]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_STATE_REFRESH]
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

		DECLARE SR CURSOR LOCAL FOR
			SELECT DISTINCT ServiceID
			FROM dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId;

		OPEN SR

		DECLARE @SERVICE INT

		FETCH NEXT FROM SR INTO @SERVICE

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC dbo.SERVICE_STATE_UPDATE @SERVICE

			FETCH NEXT FROM SR INTO @SERVICE
		END

		CLOSE SR
		DEALLOCATE SR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_STATE_REFRESH] TO rl_service_state_u;
GO
