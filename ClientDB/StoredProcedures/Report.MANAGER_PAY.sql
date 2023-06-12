USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[MANAGER_PAY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[MANAGER_PAY]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[MANAGER_PAY]
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

		DECLARE MANAGER CURSOR LOCAL FOR
			SELECT ManagerID, ManagerName
			FROM dbo.ManagerTable a
			WHERE EXISTS
				(
					SELECT *
					FROM dbo.ClientView z WITH(NOEXPAND)
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON z.ServiceStatusId = s.ServiceStatusId
					WHERE z.ManagerID = a.ManagerID
				)

		DECLARE @ID		INT
		DECLARE @NAME	NVARCHAR(128)

		DECLARE @MAN_XML NVARCHAR(MAX)
		DECLARE @MONTH	UNIQUEIDENTIFIER

		SELECT @MONTH = ID
		FROM Common.Period
		WHERE TYPE = 2 AND GETDATE() BETWEEN START AND FINISH


		OPEN MANAGER

		IF OBJECT_ID('tempdb..#man') IS NOT NULL
			DROP TABLE #man

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		CREATE TABLE #tmp
			(
				ServiceStr			NVARCHAR(128),
				CL_COUNT			INT,
				PAY_BILL			INT,
				PAY_INVOICE			INT,
				PAY_COUNT			INT,
				PAY_TOTAL_BILL		INT,
				PAY_TOTAL_INVOICE	INT,
				PAY_TOTAL			INT,
				PAY_PERCENT			INT
			)

		CREATE TABLE #man
			(
				MANAGER				NVARCHAR(128),
				CL_COUNT			INT,
				PAY_BILL			INT,
				PAY_INVOICE			INT,
				PAY_COUNT			INT,
				PAY_TOTAL_BILL		INT,
				PAY_TOTAL_INVOICE	INT,
				PAY_TOTAL			INT,
				PAY_PERCENT			INT
			)

		FETCH NEXT FROM MANAGER INTO @ID, @NAME

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @MAN_XML = '<LIST><ITEM>' + CONVERT(NVARCHAR(MAX), @ID) + '</ITEM></LIST>'

			INSERT INTO #tmp
				EXEC dbo.SERVICE_PAY_TOTAL_REPORT @MAN_XML, @MONTH, 0

			INSERT INTO #man(MANAGER, CL_COUNT, PAY_BILL, PAY_INVOICE, PAY_COUNT, PAY_TOTAL_BILL, PAY_TOTAL_INVOICE, PAY_TOTAL, PAY_PERCENT)
				SELECT @NAME, SUM(CL_COUNT), SUM(PAY_BILL), SUM(PAY_INVOICE), SUM(PAY_COUNT), SUM(PAY_TOTAL_BILL), SUM(PAY_TOTAL_INVOICE), SUM(PAY_TOTAL),
					CASE
						WHEN
							(
								SELECT SUM(PAY_COUNT)
								FROM #tmp
							) = 0 THEN 100
						ELSE
							(
								SELECT SUM(PAY_TOTAL)
								FROM #tmp
							) * 100.0
							/
							(
								SELECT SUM(PAY_COUNT)
								FROM #tmp
							)
					END
				FROM #tmp

			DELETE FROM #tmp

			FETCH NEXT FROM MANAGER INTO @ID, @NAME
		END

		CLOSE MANAGER
		DEALLOCATE MANAGER

		SELECT
			MANAGER AS [Руководитель],
			CL_COUNT AS [Кол-во клиентов], PAY_BILL AS [Оплачивают|По счету], PAY_INVOICE AS [Оплачивают|По счет-фактуре], PAY_COUNT AS [Оплачивают|Всего],
			PAY_TOTAL_BILL AS [Оплатили|По счету], PAY_TOTAL_INVOICE AS [Оплатили|По счет-фактуре], PAY_TOTAL AS [Оплатили|Всего], PAY_PERCENT AS [Процент]
		FROM #man
		ORDER BY MANAGER

		IF OBJECT_ID('tempdb..#man') IS NOT NULL
			DROP TABLE #man

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[MANAGER_PAY] TO rl_report;
GO
