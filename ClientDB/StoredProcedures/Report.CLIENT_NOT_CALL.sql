USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[CLIENT_NOT_CALL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[CLIENT_NOT_CALL]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[CLIENT_NOT_CALL]
	@PARAM	NVARCHAR(MAX) = NULL
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

		SELECT ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientFullName AS [Клиент]
		FROM dbo.ClientView a WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientTrustView WITH(NOEXPAND)
				WHERE CC_ID_CLIENT = ClientID
			) AND
			NOT EXISTS
			(
				SELECT *
				FROM
					dbo.ClientSatisfaction
					INNER JOIN dbo.ClientCall ON CC_ID = CS_ID_CALL
				WHERE CC_ID_CLIENT = ClientID
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
GRANT EXECUTE ON [Report].[CLIENT_NOT_CALL] TO rl_report;
GO
