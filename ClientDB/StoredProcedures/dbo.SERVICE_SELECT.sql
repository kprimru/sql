USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_SELECT]
	@FILTER		VARCHAR(100) = NULL,
	@DISMISS	BIT = 0
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
			ServiceID, ServiceName, a.ServicePositionID, ServicePositionName, ManagerName, ServicePhone, ServiceLogin, ServiceFirst,
			(
				SELECT COUNT(*)
				FROM dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				WHERE ClientServiceID = ServiceID
					AND STATUS = 1
			) AS ServiceCount,
			REVERSE(STUFF(REVERSE(
				(
					SELECT CT_NAME + ', '
					FROM
						dbo.City
						INNER JOIN dbo.ServiceCity ON CT_ID = ID_CITY
					WHERE ID_SERVICE = ServiceID
					ORDER BY CT_DISPLAY DESC, CT_NAME FOR XML PATH('')
				)
			), 1, 2, '')) AS CT_NAME
		FROM
			dbo.ServiceTable a
			INNER JOIN dbo.ServicePositionTable b ON a.ServicePositionID = b.ServicePositionID
			INNER JOIN dbo.ManagerTable c ON c.ManagerID = a.ManagerID
		WHERE (@FILTER IS NULL
			OR ServiceName LIKE @FILTER
			OR ServiceFullName LIKE @FILTER
			OR ServiceLogin LIKE @FILTER)
			AND (@DISMISS = 1 OR ServiceDismiss IS NULL)
		ORDER BY ServiceName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SERVICE_SELECT] TO rl_personal_service_r;
GO