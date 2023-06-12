USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_TRUST_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_TRUST_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_TRUST_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT,
	@STATUS		VARCHAR(MAX),
	@TP			SMALLINT = NULL
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

		IF @TP IS NULL OR @TP = 0
			SELECT ClientID, ClientFullName, ServiceName, ManagerName, CC_DATE, CC_USER, CT_MAKE_DATA, CT_TRUST_STR
			FROM
				dbo.ClientTrustView
				INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = CC_ID_CLIENT
				INNER JOIN dbo.GET_TABLE_FROM_LIST(@STATUS, ',') ON CT_TRUST_STATUS = Item
			WHERE (CC_DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (CC_DATE <= @END OR @END IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			ORDER BY CC_DATE DESC, ManagerName, ServiceName, ClientFullName
		ELSE
			SELECT
				ClientID, ClientFullName, ServiceName, ManagerName,
				(
					SELECT MAX(CC_DATE)
					FROM dbo.ClientTrustView
					WHERE CC_ID_CLIENT = ClientID
				) AS CC_DATE, NULL AS CC_USER, NULL AS CT_MAKE_DATA, NULL AS CT_TRUST_STR
			FROM
				dbo.ClientView a WITH(NOEXPAND)
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
			WHERE (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ClientTrustView
						WHERE CC_ID_CLIENT = ClientID
							AND (CC_DATE >= @BEGIN OR @BEGIN IS NULL)
							AND (CC_DATE <= @END OR @END IS NULL)
					)
			ORDER BY ManagerName, ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_TRUST_FILTER] TO rl_filter_trust;
GO
