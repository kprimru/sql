﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[SERVICE_SALARY_AUTO_CALC]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[SERVICE_SALARY_AUTO_CALC]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Salary].[SERVICE_SALARY_AUTO_CALC]
	@MONTH	UNIQUEIDENTIFIER
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

		IF EXISTS
			(
				SELECT *
				FROM Salary.Service
				WHERE ID_MONTH = @MONTH
			)
		BEGIN
			RAISERROR ('В этом месяце уже есть расчитанные СИ. Автоматическое заполнение невозможно', 16, 1)

			RETURN
		END

		DECLARE SRVC CURSOR LOCAL FOR
			SELECT ServiceID, ServicePositionID
			FROM dbo.ServiceTable a
			WHERE ServiceDismiss IS NULL
				AND EXISTS
					(
						SELECT *
						FROM dbo.ClientView b WITH(NOEXPAND)
						INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.ServiceStatusId = s.ServiceStatusId
						WHERE a.ServiceID = b.ServiceID
					)
				AND ServiceName NOT LIKE 'самостоятельно%'
				AND ManagerID NOT IN (22, 5, 23)

		OPEN SRVC

		DECLARE @SERVICE	INT
		DECLARE @POSITION	INT
		DECLARE @ID			UNIQUEIDENTIFIER

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
			(
				CHECKED			BIT,
				ID_HOST			INT,
				DISTR			INT,
				COMP			INT,
				DISTR_STR		NVARCHAR(64),
				CLIENT			NVARCHAR(128),
				OPER			NVARCHAR(128),
				OPER_NOTE		NVARCHAR(128),
				WEIGHT_OLD		DECIMAL(8, 4),
				WEIGHT_NEW		DECIMAL(8, 4),
				WEIGHT_DELTA	DECIMAL(8, 4),
				PRICE_OLD		MONEY,
				PRICE_NEW		MONEY,
				PRICE_DELTA		MONEY,
				ServiceID		INT,
				ServiceName		NVARCHAR(128)
			)

		DECLARE @HOST			INT
		DECLARE @DISTR			INT
		DECLARE	@COMP			INT
		DECLARE	@DISTR_STR		NVARCHAR(64)
		DECLARE @CLIENT			NVARCHAR(256)
		DECLARE @OPER			NVARCHAR(64)
		DECLARE	@OPER_NOTE		NVARCHAR(256)
		DECLARE	@WEIGHT_OLD		DECIMAL(8, 4)
		DECLARE	@WEIGHT_NEW		DECIMAL(8, 4)
		DECLARE	@PRICE_OLD		MONEY
		DECLARE	@PRICE_NEW		MONEY

		FETCH NEXT FROM SRVC INTO @SERVICE, @POSITION

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @ID = NULL

			EXEC Salary.SERVICE_SALARY_SAVE @ID OUTPUT, @MONTH, @SERVICE, @POSITION, 0

			EXEC Salary.SERVICE_SALARY_CLIENT_IMPORT @ID, @MONTH, @SERVICE
			EXEC Salary.SERVICE_SALARY_STUDY_IMPORT @ID, @MONTH, @SERVICE

			DELETE FROM #distr

			INSERT INTO #distr
				EXEC Salary.SERVICE_SALARY_DISTR_IMPORT_SELECT @MONTH, @SERVICE

			DECLARE DSTR CURSOR LOCAL FOR
				SELECT CLIENT, ID_HOST, DISTR, COMP, DISTR_STR, OPER, OPER_NOTE, PRICE_OLD, PRICE_NEW, WEIGHT_OLD, WEIGHT_NEW
				FROM #distr
				WHERE CHECKED = 1

			OPEN DSTR

			FETCH NEXT FROM DSTR INTO @CLIENT, @HOST, @DISTR, @COMP, @DISTR_STR, @OPER, @OPER_NOTE, @PRICE_OLD, @PRICE_NEW, @WEIGHT_OLD, @WEIGHT_NEW

			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC Salary.SERVICE_SALARY_DISTR_IMPORT @ID, @CLIENT, @HOST, @DISTR, @COMP, @DISTR_STR, @OPER, @OPER_NOTE, @PRICE_OLD, @PRICE_NEW, @WEIGHT_OLD, @WEIGHT_NEW

				FETCH NEXT FROM DSTR INTO @CLIENT, @HOST, @DISTR, @COMP, @DISTR_STR, @OPER, @OPER_NOTE, @PRICE_OLD, @PRICE_NEW, @WEIGHT_OLD, @WEIGHT_NEW
			END

			CLOSE DSTR
			DEALLOCATE DSTR

			FETCH NEXT FROM SRVC INTO @SERVICE, @POSITION
		END

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CLOSE SRVC
		DEALLOCATE SRVC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[SERVICE_SALARY_AUTO_CALC] TO rl_salary;
GO
