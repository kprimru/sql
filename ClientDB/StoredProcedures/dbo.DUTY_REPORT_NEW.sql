USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DUTY_REPORT_NEW]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@DUTY		INT = NULL
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

		IF OBJECT_ID('tempdb..#duty') IS NOT NULL
			DROP TABLE #duty	

		SELECT (
			   SELECT dbo.DateOf(MIN(g.ClientDutyDateTime))
			   FROM dbo.ClientDutyTable g 
			   WHERE g.ClientID = b.ClientID 
					AND g.STATUS = 1
					AND dbo.DateOf(g.ClientDutyDateTime) BETWEEN @BEGIN AND @END
			 ) AS MinDutyDate, a.ClientDutyID, CLientFullName, dbo.DateOf(ClientDutyDateTime) AS ClientDutyDate,
			 DutyName, dbo.DateOf(ClientDutyDateTime) AS DutyDate,
			ClientDutyDocs,
			CASE
				WHEN ClientDutyComplete = 1 THEN 'Запрос отработан'
				WHEN ClientDutyComplete = 0 AND ClientDutyUncomplete = 0 AND ClientDutyNPO = 1 THEN 'Отправлен запрос в НПО'
				WHEN ClientDutyComplete = 0 AND ClientDutyUncomplete = 1 THEN 'Запрос отработан, нет возможности выполнить'
				ELSE 'Неизвестен статус запроса'
			END AS ClientDutyStatus,
			dbo.DateOf(ClientDutyAnswer) AS ClientDutyAnswer

			INTO #duty
		FROM 
			dbo.ClientDutyTable a 
			INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID 
			INNER JOIN dbo.DutyTable c ON c.DutyID = a.DutyID
		WHERE dbo.DateOf(ClientDutyDateTime) BETWEEN @BEGIN AND @END
			AND a.STATUS = 1		
			AND (ClientServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (c.DutyID = @DUTY OR @DUTY IS NULL)
			AND b.STATUS = 1
		ORDER BY MinDutyDate, ClientFullName, ClientDutyDate, ClientDutyID

		SELECT 
			MinDutyDate, ClientDutyID, ClientFullName, ClientDutyDate, DutyName, DutyDate,
			ClientDutyDocs, ClientDutyStatus, ClientDutyAnswer,
			(
				SELECT COUNT(*)
				FROM #duty b
				WHERE a.ClientFullName = b.ClientFullName
			) AS DutyCount
		FROM #duty a
		ORDER BY MinDutyDate, ClientFullName, ClientDutyDate, ClientDutyID

		IF OBJECT_ID('tempdb..#duty') IS NOT NULL
			DROP TABLE #duty
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END