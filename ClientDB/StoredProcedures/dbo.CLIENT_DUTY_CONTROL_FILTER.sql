USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_CONTROL_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT,
	@ANS_STAT	TINYINT,
	@SAT_STAT	TINYINT,
	@ANS_CNT	INT = NULL OUTPUT,
	@SAT_CNT	INT = NULL OUTPUT,
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
		BEGIN
			IF OBJECT_ID('tempdb..#duty') IS NOT NULL
				DROP TABLE #duty

			SELECT
				ClientID, ClientFullName, ServiceName, ManagerName, CC_DATE, CC_USER,
				CASE CDC_ANSWER WHEN 0 THEN 'Да' ELSE 'Нет' END AS CDC_ANS,
				CASE CDC_SATISF WHEN 0 THEN 'Да' ELSE 'Нет' END AS CDC_SAT,
				CDC_NOTE
			INTO #duty
			FROM
				dbo.ClientDutyControl a
				INNER JOIN dbo.ClientCall b ON a.CDC_ID_CALL = b.CC_ID
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.CC_ID_CLIENT
			WHERE (CC_DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (CC_DATE <= @END OR @END IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (@ANS_STAT = 0 OR @ANS_STAT = 1 AND CDC_ANSWER = 0 OR @ANS_STAT = 2 AND CDC_ANSWER = 1)
				AND (@SAT_STAT = 0 OR @SAT_STAT = 1 AND CDC_SATISF = 0 OR @SAT_STAT = 2 AND CDC_SATISF = 1)
			ORDER BY CC_DATE DESC, ManagerName, ServiceName, ClientFullName

			SELECT *
			FROM #duty
			ORDER BY CC_DATE DESC, ManagerName, ServiceName, ClientFullName

			SET @ANS_CNT = (SELECT COUNT(*) FROM #duty WHERE CDC_ANS = 'Нет')
			SET @SAT_CNT = (SELECT COUNT(*) FROM #duty WHERE CDC_SAT = 'Нет')

			IF OBJECT_ID('tempdb..#duty') IS NOT NULL
				DROP TABLE #duty
		END
		ELSE
			SELECT
				ClientID, ClientFullName, ServiceName, ManagerName,
				(
					SELECT MAX(CC_DATE)
					FROM
						dbo.ClientDutyControl a
						INNER JOIN dbo.ClientCall b ON a.CDC_ID_CALL = b.CC_ID
					WHERE CC_ID_CLIENT = ClientID
				) AS CC_DATE,
				NULL AS CC_USER, NULL AS CDC_ANS, NULL AS CDC_SAT, NULL AS CDC_NOTE
			FROM dbo.ClientView c WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						dbo.ClientDutyControl a
						INNER JOIN dbo.ClientCall b ON a.CDC_ID_CALL = b.CC_ID
					WHERE CC_ID_CLIENT = ClientID
						AND (CC_DATE >= @BEGIN OR @BEGIN IS NULL)
						AND (CC_DATE <= @END OR @END IS NULL)
				)
				AND EXISTS
				(
					SELECT *
					FROM dbo.ClientDutyTable z
					WHERE c.CLientID = z.ClientID
						AND (ClientDutyDateTime >= @BEGIN OR @BEGIN IS NULL)
						AND (ClientDutyDateTime < DATEADD(DAY, 1, @END) OR @END IS NULL)
				)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			ORDER BY ManagerName, ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_CONTROL_FILTER] TO rl_filter_duty_control;
GO