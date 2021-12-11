USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[INNOVATION_EMPTY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[INNOVATION_EMPTY]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[INNOVATION_EMPTY]
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

		DECLARE @INN UNIQUEIDENTIFIER

		SELECT TOP 1 @INN = ID
		FROM dbo.Innovation
		ORDER BY START DESC


		SELECT ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientFullName AS [Клиент]
		FROM
			dbo.ClientInnovation a
			INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ID_CLIENT = ClientID
		WHERE ID_INNOVATION = @INN
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientInnovationPersonal b
					WHERE b.ID_INNOVATION = a.ID
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
GRANT EXECUTE ON [Report].[INNOVATION_EMPTY] TO rl_report;
GO
