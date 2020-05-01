USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_STATE_TOTAL_PRINT]
	@MANAGER	NVARCHAR(MAX),
	@TP			NVARCHAR(MAX)
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

		IF ISNULL(@TP, '') = ''
		BEGIN
			SET @TP = ''
			SELECT @TP = @TP + ',' + TP
			FROM
				(
					SELECT DISTINCT TP
					FROM dbo.ServiceStateDetail
				) AS o_O
			WHERE TP <> 'PAY'

			SET @TP = LEFT(@TP, LEN(@TP) - 1)
		END


		SELECT DISTINCT a.ServiceName, a.ManagerName, f.ClientFullName AS TP_NOTE, DETAIL AS NOTE, DATE AS DT, TP_NAME, TP_ORD, TP_NOTE AS GRP_NAME,
			(
				SELECT COUNT(*)
				FROM dbo.ServiceStateDetail z
				WHERE z.ID_STATE = b.ID
					AND z.TP = d.TP_NAME
			) AS GRP_CNT
		FROM
			(
				SELECT b.ServiceID, b.ServiceName, ManagerName
				FROM
					dbo.TableIDFromXML(@MANAGER) a
					INNER JOIN dbo.ServiceTable b ON a.ID = b.ManagerID
					INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ServiceID = b.ServiceID
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
			) AS a
			INNER JOIN dbo.ServiceState b ON b.ID_SERVICE = a.ServiceID AND b.STATUS = 1
			INNER JOIN dbo.ServiceStateDetail c ON b.ID = c.ID_STATE
			INNER JOIN dbo.ServiceStateTypeView d ON c.TP = d.TP_NAME
			INNER JOIN dbo.GET_STRING_TABLE_FROM_LIST(@TP, ',') e ON e.Item = d.TP_NAME
			INNER JOIN dbo.ClientTable f ON f.ClientID = c.ID_CLIENT
		ORDER BY ManagerName, ServiceName, TP_ORD, TP_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SERVICE_STATE_TOTAL_PRINT] TO rl_service_state_r;
GO