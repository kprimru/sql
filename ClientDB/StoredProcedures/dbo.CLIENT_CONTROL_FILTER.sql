USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTROL_FILTER]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	INT,
	@STATUS		INT,
	@COMMENT	VARCHAR(100),
	@TYPE		INT = 0,
	@NOTIFY_B	SMALLDATETIME = NULL,
	@NOTIFY_E	SMALLDATETIME = NULL
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
			ClientID, ClientFullName, ManagerName, ServiceName,
			CONVERT(DATETIME, CONVERT(VARCHAR(20), CC_DATE, 112), 112) AS CC_DATE_STR,
			CONVERT(DATETIME, CONVERT(VARCHAR(20), CC_BEGIN, 112), 112) AS CC_BEGIN_STR,
			CC_TEXT, CC_REMOVE_DATE, CC_AUTHOR, CC_BEGIN,
			CASE CC_TYPE
				WHEN 1 THEN 'Аудит'
				WHEN 2 THEN 'Руководитель группы'
				WHEN 3 THEN 'Дежурная служба'
				WHEN 4 THEN 'Начальник отдела'
				WHEN 5 THEN 'Юрист'
				ELSE ''
			END AS CC_TYPE_STR
		FROM
			[dbo].[ClientList@Get?Read]()
			INNER JOIN dbo.ClientView a WITH(NOEXPAND) ON a.ClientID = WCL_ID
			INNER JOIN dbo.ClientControl d ON d.CC_ID_CLIENT = a.ClientID
		WHERE (CC_DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (CC_DATE < DATEADD(DAY, 1, @END) OR @END IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND
				(
					@STATUS = -1
					OR @STATUS = 0
					OR @STATUS = 1 AND CC_REMOVE_DATE IS NULL
					OR @STATUS = 2 AND CC_REMOVE_DATE IS NOT NULL
				)
			AND (CC_TEXT LIKE @COMMENT OR @COMMENT IS NULL)
			AND (CC_TYPE = @TYPE OR @TYPE = 0)
			AND (
					CC_BEGIN IS NULL
					OR
					(CC_BEGIN >= @NOTIFY_B OR @NOTIFY_B IS NULL)
					AND (CC_BEGIN <= @NOTIFY_E OR @NOTIFY_E IS NULL)
				)
		ORDER BY CC_DATE_STR DESC, ManagerName, ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTROL_FILTER] TO rl_filter_control;
GO
