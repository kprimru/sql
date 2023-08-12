USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[CLIENT_LIST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[CLIENT_LIST]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Report].[CLIENT_LIST]
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

		SELECT
			b.ManagerName AS [Рук-ль], b.ServiceName AS [СИ], b.ClientFullName AS [Клиент],
			T.Name AS [Тип ограничения], R.[Comment] AS [Описание]
		FROM dbo.ClientView b WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.ServiceStatusId = s.ServiceStatusId
		INNER JOIN [dbo].[Clients:Restrictions] AS r ON r.Client_Id = b.ClientID
		INNER JOIN [dbo].[Clients:Restrictions->Types] AS T ON t.Id = R.[Type_Id]
		ORDER BY ManagerName, ServiceName, b.ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[CLIENT_LIST] TO rl_report;
GO
