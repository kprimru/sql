USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_GRAPH_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @SERVICE INT

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @SERVICE = ServiceID
		FROM dbo.ServiceTable
		WHERE ServiceLogin = ORIGINAL_LOGIN()

		SELECT COUNT(*) AS CNT
		FROM
			(
				SELECT ClientID
				FROM dbo.ServiceGraphView
				WHERE ClientServiceID = @SERVICE
					AND GR_ERROR IS NOT NULL

				UNION ALL

				SELECT ClientID
				FROM
					dbo.ClientTable a
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				WHERE a.ClientServiceID = @SERVICE
					AND a.STATUS = 1
					AND
						(
							DayID IS NULL
							OR
							ServiceStart IS NULL
							OR
							ServiceTime IS NULL
						)
			) AS o_O

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_GRAPH_WARNING] TO rl_graph_warning;
GO
