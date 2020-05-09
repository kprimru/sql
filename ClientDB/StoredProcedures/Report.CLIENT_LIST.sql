USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[CLIENT_LIST]
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
			b.ManagerName AS [Рук-ль], b.ServiceName AS [СИ], a.ClientFullName AS [Клиент],
			USR_CHECK AS [Файлы USR], STT_CHECK AS [Файлы STT], HST_CHECK AS [Файлы HST], INET_CHECK AS [Нет Интернета]
		FROM
			dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
		WHERE STATUS = 1
			AND
				(
					HST_CHECK = 0
					OR
					STT_CHECK = 0
					OR
					USR_CHECK = 0
					OR
					INET_CHECK = 1
				)
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