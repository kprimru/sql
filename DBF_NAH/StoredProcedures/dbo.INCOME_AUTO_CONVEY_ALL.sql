USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[INCOME_AUTO_CONVEY_ALL]
	@bill BIT = 1,
	@prepay BIT = 1,
	@report BIT = 1,
	@soid SMALLINT = NULL,
	@act BIT = 1
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

		DECLARE @ssoid SMALLINT

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		CREATE TABLE #tmp
			(
				DIS_ID INT,
				DIS_STR VARCHAR(30),
				ID_PRICE MONEY,
				PR_ID SMALLINT,
				PR_DATE SMALLDATETIME,
				ID_PREPAY BIT
			)

		DECLARE INC CURSOR LOCAL FOR
			SELECT DISTINCT IN_ID, IN_DATE, IN_SUM
			FROM dbo.IncomeView
			WHERE IN_REST > 0
			ORDER BY IN_DATE

		OPEN INC

		DECLARE @inid INT
		DECLARE @indate SMALLDATETIME
		DECLARE @insum MONEY

		FETCH NEXT FROM INC INTO @inid, @indate, @insum

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @insum > 0
			BEGIN
				DELETE FROM #tmp

				IF @soid IS NULL
					SET @ssoid = 2
				ELSE
					SET @ssoid = @soid

				INSERT INTO #tmp
					EXEC dbo.INCOME_AUTO_CONVEY @inid, NULL, @bill, 0, @ssoid, NULL, @report, @act

				IF @prepay = 0
					DELETE FROM #tmp WHERE ID_PREPAY = 1

				INSERT INTO dbo.IncomeDistrTable(ID_ID_INCOME, ID_ID_DISTR, ID_PRICE, ID_DATE, ID_ID_PERIOD, ID_PREPAY)
					SELECT @inid, DIS_ID, ID_PRICE, @indate, PR_ID, ID_PREPAY
					FROM #tmp

				DELETE FROM #tmp

				IF @soid IS NULL
					SET @ssoid = 1
				ELSE
					SET @ssoid = @soid

				INSERT INTO #tmp
					EXEC dbo.INCOME_AUTO_CONVEY @inid, NULL, @bill, @prepay, @ssoid, NULL, @report, @act

				IF @prepay = 0
					DELETE FROM #tmp WHERE ID_PREPAY = 1

				INSERT INTO dbo.IncomeDistrTable(ID_ID_INCOME, ID_ID_DISTR, ID_PRICE, ID_DATE, ID_ID_PERIOD, ID_PREPAY)
					SELECT @inid, DIS_ID, ID_PRICE, @indate, PR_ID, ID_PREPAY
					FROM #tmp
			END
			ELSE
			BEGIN
				DELETE FROM #tmp

				IF @soid IS NULL
					SET @ssoid = 2
				ELSE
					SET @ssoid = @soid

				INSERT INTO #tmp
					EXEC dbo.INCOME_OUT_AUTO_CONVEY @inid, @ssoid

				IF @prepay = 0
					DELETE FROM #tmp WHERE ID_PREPAY = 1

				INSERT INTO dbo.IncomeDistrTable(ID_ID_INCOME, ID_ID_DISTR, ID_PRICE, ID_DATE, ID_ID_PERIOD, ID_PREPAY)
					SELECT @inid, DIS_ID, ID_PRICE, @indate, PR_ID, ID_PREPAY
					FROM #tmp

				DELETE FROM #tmp

				IF @soid IS NULL
					SET @ssoid = 1
				ELSE
					SET @ssoid = @soid

				INSERT INTO #tmp
					EXEC dbo.INCOME_OUT_AUTO_CONVEY @inid, @ssoid

				IF @prepay = 0
					DELETE FROM #tmp WHERE ID_PREPAY = 1

				INSERT INTO dbo.IncomeDistrTable(ID_ID_INCOME, ID_ID_DISTR, ID_PRICE, ID_DATE, ID_ID_PERIOD, ID_PREPAY)
					SELECT @inid, DIS_ID, ID_PRICE, @indate, PR_ID, ID_PREPAY
					FROM #tmp
			END

			FETCH NEXT FROM INC INTO @inid, @indate, @insum
		END

		CLOSE INC
		DEALLOCATE INC


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
