USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_COMMON_REPORT]
	@DATE		SMALLDATETIME,
	@DS_PERIOD	TINYINT,
	@SERVICE	INT = NULL,
	@MANAGER	INT = NULL,
	@STATUS		INT = NULL
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
			ClientFullName, ServiceName, ManagerName,
			CASE
				WHEN LastStudy IS NULL THEN 'Не обучался'
				WHEN LastStudy <= DATEADD(YEAR, -1, @DATE) THEN CONVERT(VARCHAR(20), DATEPART(YEAR, LastStudy))
				ELSE CONVERT(CHAR(1),((MONTH(LastStudy) - 1) / 3) % 4 + 1) + ' квартал ' + CONVERT(CHAR(4), YEAR(LastStudy))
			END AS LastStudy,
			CASE
				WHEN LastDuty IS NULL THEN 'Не обращался'
				ELSE DATENAME(MONTH, LastDuty) + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, LastDuty))
			END AS LastDuty,
			DutyCount
		FROM
			(
				SELECT
					ClientFullName, ServiceName, ManagerName,
					(
						SELECT MAX(DATE)
						FROM dbo.ClientStudy d
						WHERE d.ID_CLIENT = a.ClientID
							AND DATE <= @DATE
							AND STATUS = 1
					) AS LastStudy,
					(
						SELECT MAX(ClientDutyDateTime)
						FROM dbo.ClientDutyTable e
						WHERE e.ClientID = a.ClientID
							AND ClientDutyDateTime <= @DATE
							AND STATUS = 1
					) AS LastDuty,
					(
						SELECT COUNT(ClientDutyID)
						FROM dbo.ClientDutyTable f
						WHERE f.ClientID = a.ClientID
							AND ClientDutyDate <= @DATE
							AND ClientDutyDate >= DATEADD(MONTH, -@DS_PERIOD, @DATE)
							AND STATUS = 1
					) AS DutyCount
				FROM dbo.ClientView a WITH(NOEXPAND)
				WHERE (ManagerID = @MANAGER OR @MANAGER IS NULL)
					AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
					AND (ServiceStatusID = @STATUS OR @STATUS IS NULL)
			) AS dt
		ORDER BY ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_COMMON_REPORT] TO rl_report_common_client;
GO
