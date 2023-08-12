USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SATISFACTION_STAT_REPORT_NEW]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SATISFACTION_STAT_REPORT_NEW]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SATISFACTION_STAT_REPORT_NEW]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	INT
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		SELECT
			ServiceName,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientTable a
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				WHERE ServiceID = ClientServiceID
					AND STATUS = 1
			) AS ClientCount,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
					INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
				WHERE ServiceID = ClientServiceID
					AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
					AND STATUS = 1
			) AS CallCount,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
					INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
					INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
				WHERE ServiceID = ClientServiceID
					AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
					AND STT_RESULT = 1
					AND STATUS = 1
			) AS SatCount,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
					INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
					INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
				WHERE ServiceID = ClientServiceID
					AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
					AND STT_RESULT = 0
					AND STATUS = 1
			) AS UnSatCount
		FROM dbo.ServiceTable a
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND EXISTS
			(
				SELECT *
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
					INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
				WHERE ServiceID = ClientServiceID
					AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
					AND STATUS = 1
			)
		ORDER BY ServiceName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SATISFACTION_STAT_REPORT_NEW] TO rl_report_client_satisfaction;
GO
