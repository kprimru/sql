USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/
CREATE PROCEDURE [dbo].[INCOME_OUT_AUTO_CONVEY]
	@incomeid INT,
	@startperiodid SMALLINT = NULL,
	@bill BIT = 1,
	@prepay BIT = 1,
	@soid SMALLINT = 1,
	@distr VARCHAR(MAX) = NULL,
	@report BIT = 1,
	@psum MONEY = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr

	CREATE TABLE #distr
		(
			DIS_ID INT
		)

	IF @distr IS NOT NULL
		INSERT INTO #distr
			SELECT * FROM dbo.GET_TABLE_FROM_LIST(@distr, ',')
	ELSE
		INSERT INTO #distr
			SELECT DISTINCT SL_ID_DISTR
			FROM dbo.SaldoTable
			WHERE SL_ID_CLIENT = 
					(
						SELECT IN_ID_CLIENT
						FROM dbo.IncomeTable 
						WHERE IN_ID = @incomeid
					)
			
	IF @soid IS NULL
		SELECT TOP 1 @soid = SYS_ID_SO
		FROM 
			dbo.DistrView a INNER JOIN 
			#distr b ON a.DIS_ID = b.DIS_ID		

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp

	CREATE TABLE #temp
		(
			ID_ID INT IDENTITY(1, 1),
			ID_ID_DISTR INT,
			ID_PRICE MONEY,
			ID_DATE SMALLDATETIME,
			ID_ID_PERIOD SMALLINT NOT NULL,
			ID_PREPAY BIT,
			PAYED BIT,
			PR_DATE SMALLDATETIME,
			SYS_ORDER INT
		)
	
	DECLARE @clientid INT
	DECLARE @indate SMALLDATETIME
	DECLARE @pricesum MONEY
	
	
	
	SELECT @clientid = IN_ID_CLIENT, @indate = IN_DATE, @pricesum = IN_REST
	FROM dbo.IncomeView 
	WHERE IN_ID = @incomeid	

	--SELECT @clientid, @indate, @pricesum

	DECLARE @prid SMALLINT
	DECLARE @prdate SMALLDATETIME
	DECLARE @oldprid SMALLINT
	DECLARE @firstprid SMALLINT

	DECLARE @idid INT
	DECLARE @i INT

	
	

	INSERT INTO #temp
		(
			ID_ID_DISTR, ID_PRICE, ID_ID_PERIOD, ID_PREPAY, PAYED, PR_DATE, SYS_ORDER
		)
		SELECT 
			--BD_ID_DISTR, 
			ID_ID_DISTR,
			ID_PRICE,				
			PR_ID, 0, 0, PR_DATE, SYS_ORDER
		FROM 
			dbo.IncomeTable INNER JOIN
			dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID INNER JOIN
			dbo.PeriodTable ON PR_ID = ID_ID_PERIOD INNER JOIN
			dbo.DistrView a ON DIS_ID = ID_ID_DISTR INNER JOIN
			#distr b ON a.DIS_ID = b.DIS_ID
		WHERE ID_PRICE > 0 
			/*AND NOT EXISTS
				(
					SELECT *
					FROM 
						dbo.ActTable INNER JOIN
						dbo.ActDistrTable ON ACT_ID = AD_ID_ACT
					WHERE ACT_ID_CLIENT = IN_ID_CLIENT
						AND ID_ID_DISTR = AD_ID_DISTR
						AND ID_ID_PERIOD = AD_ID_PERIOD
				)*/
			AND IN_ID_CLIENT = @clientid 
			AND SYS_ID_SO = @soid			
			ORDER BY PR_DATE DESC, SYS_ORDER
		
		SET @i = 0

		WHILE @pricesum < 0 
		BEGIN
			
			--SELECT @i, @pricesum
			SET @i = 
				(
					SELECT MIN(ID_ID)
					FROM #temp
					WHERE ID_ID > @i AND PAYED = 0
				)

			IF @i IS NULL
				BREAK

			--SELECT @pricesum
					
			SELECT @pricesum = @pricesum + ID_PRICE
			FROM #temp
			WHERE ID_ID = @i				
			
			UPDATE #temp
			SET PAYED = 1
			WHERE ID_ID = @i

			--SELECT * FROM #temp
				
			IF @pricesum >= 0
			BEGIN
				
				UPDATE #temp
				SET ID_PRICE = ID_PRICE - ABS(@pricesum)
				WHERE ID_ID = @i
				
				--DELETE FROM #temp WHERE ID_ID > @i

				SET @pricesum = 0

				--SELECT * FROM #temp			
			END
		END

		DELETE FROM #temp WHERE ID_ID > @i
	

	SELECT DIS_ID, DIS_STR, SUM((-ID_PRICE)) AS ID_PRICE, PR_ID, b.PR_DATE, ID_PREPAY, CONVERT(BIT, 0) AS ID_ACTION
	FROM 
		#temp a INNER JOIN
		dbo.PeriodTable b ON ID_ID_PERIOD = PR_ID INNER JOIN
		dbo.DistrView ON DIS_ID = ID_ID_DISTR
	WHERE ID_PRICE <> 0
	GROUP BY DIS_ID, DIS_STR, PR_ID, b.PR_DATE, a.PR_DATE, a.SYS_ORDER, ID_PREPAY
	ORDER BY a.PR_DATE, a.SYS_ORDER

	--SELECT @pricesum

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp

	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr

END