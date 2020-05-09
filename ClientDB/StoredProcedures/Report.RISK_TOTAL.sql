USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[RISK_TOTAL]
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

		DECLARE @SERVICE	INT
		DECLARE @AVG NVARCHAR(16)

		DECLARE S CURSOR LOCAL FOR
			SELECT DISTINCT ServiceID
			FROM dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId;

		OPEN S

		IF OBJECT_ID('tempdb..#t') IS NOT NULL
			DROP TABLE #t

		CREATE TABLE #t
			(
				RN	INT,
				ClientID	INT,
				ClientFullName	NVARCHAR(512),
				USR_CNT			INT,
				ServiceType		NVARCHAR(64),
				ServiceName		NVARCHAR(128),
				ManagerName		NVARCHAR(128),
				SEARCH			SMALLINT,
				SEARCH_AVG		SMALLINT,
				DUTY			SMALLINT,
				DUTY_CNT		SMALLINT,
				RIVAL			SMALLINT,
				RIVAL_CNT		SMALLINT,
				UPDATES			SMALLINT,
				UPDATES_CNT		SMALLINT,
				STUDY			SMALLINT,
				STUDY_CNT		SMALLINT,
				SEMINAR			SMALLINT,
				SEMINAR_CNT		SMALLINT,
				ERR_CNT			SMALLINT,
				SEARCH_PARAM	NVARCHAR(64),
				DUTY_PARAM		NVARCHAR(64),
				RIVAL_PARAM		NVARCHAR(64),
				UPDATE_PARAM	NVARCHAR(64),
				STUDY_PARAM		NVARCHAR(64),
				SEMINAR_PARAM	NVARCHAR(64)
			)

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				ManagerName	NVARCHAR(128),
				ServiceName	NVARCHAR(128),
				CLIENT		SMALLINT,
				DUTY		SMALLINT,
				RIVAL		SMALLINT,
				STUDY		SMALLINT,
				SEMINAR		SMALLINT,
				ERR			NVARCHAR(16)
			)

		FETCH NEXT FROM S INTO @SERVICE

		WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM #t

			INSERT INTO #t
				EXEC dbo.RISK_REPORT NULL, @SERVICE, NULL, NULL, NULL, @AVG OUTPUT

			INSERT INTO #result(ManagerName, ServiceName, CLIENT, DUTY, RIVAL, STUDY, SEMINAR, ERR)
				SELECT ManagerName, ServiceName, COUNT(*), SUM(DUTY_CNT), SUM(RIVAL_CNT), SUM(STUDY_CNT), SUM(SEMINAR), @AVG
				FROM #t
				GROUP BY ServiceName, ManagerName

			FETCH NEXT FROM S INTO @SERVICE
		END

		CLOSE S
		DEALLOCATE S

		SELECT
			ServiceName AS [СИ], ManagerName AS [Руководитель], CLIENT AS [Всего клиентов], DUTY AS [Звонков в ДС],
			RIVAL AS [Конкурентов], STUDY AS [Проведено обучений], SEMINAR AS [Участий в семинарах], ERR AS [Среднее кол-во ошибок]
		FROM #result
		ORDER BY ManagerName, ServiceName

		IF OBJECT_ID('tempdb..#t') IS NOT NULL
			DROP TABLE #t

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[RISK_TOTAL] TO rl_report;
GO