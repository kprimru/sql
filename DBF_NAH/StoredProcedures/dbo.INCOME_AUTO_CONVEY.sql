USE [DBF_NAH]
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
ALTER PROCEDURE [dbo].[INCOME_AUTO_CONVEY]
	@incomeid INT,
	@startperiodid SMALLINT = NULL,
	@bill BIT = 1,
	@prepay BIT = 1,
	@soid SMALLINT = 1,
	@distr VARCHAR(MAX) = NULL,
	@report BIT = 1,
	@act BIT = 1,
	@rest MONEY = NULL
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

		DECLARE @z INT
		DECLARE @y INT

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
				SELECT DIS_ID
				FROM dbo.ClientDistrView
				WHERE CD_ID_CLIENT =
						(
							SELECT IN_ID_CLIENT
							FROM dbo.IncomeTable
							WHERE IN_ID = @incomeid
						)
				UNION

				SELECT a.DIS_ID
				FROM
					dbo.DistrView a WITH(NOEXPAND) INNER JOIN
					dbo.DistrView b WITH(NOEXPAND) ON a.DIS_NUM = b.DIS_NUM
								AND a.DIS_COMP_NUM = b.DIS_COMP_NUM
								AND a.HST_ID = b.HST_ID INNER JOIN
					dbo.ClientDistrView c ON c.DIS_ID = b.DIS_ID
				WHERE CD_ID_CLIENT =
						(
							SELECT IN_ID_CLIENT
							FROM dbo.IncomeTable
							WHERE IN_ID = @incomeid
						)

		IF @soid IS NULL
			SELECT TOP 1 @soid = SYS_ID_SO
			FROM
				dbo.DistrView a WITH(NOEXPAND) INNER JOIN
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



		SELECT @clientid = IN_ID_CLIENT, @indate = IN_DATE, @pricesum = ISNULL(@rest, IN_REST)
		FROM dbo.IncomeView
		WHERE IN_ID = @incomeid

		DECLARE @prid SMALLINT
		DECLARE @prdate SMALLDATETIME
		DECLARE @oldprid SMALLINT
		DECLARE @firstprid SMALLINT

		DECLARE @idid INT

		--разноска по долгам (если есть отрицательные платежи)
		IF (1 = 1) AND (@pricesum > 0)
		BEGIN
			INSERT INTO #temp
				(
					ID_ID_DISTR, ID_PRICE, ID_ID_PERIOD, ID_PREPAY, PAYED, PR_DATE, SYS_ORDER
				)
				SELECT ID_ID_DISTR,
					(
						SELECT SUM(ID_PRICE)
						FROM
							dbo.IncomeTable z INNER JOIN
							dbo.IncomeDistrTable y ON z.IN_ID = y.ID_ID_INCOME
						WHERE y.ID_ID_PERIOD =  o_O.ID_ID_PERIOD
							AND y.ID_ID_DISTR = o_O.ID_ID_DISTR
					) AS ID_PRICE, ID_ID_PERIOD, 0, 0, PR_DATE, SYS_ORDER
				FROM 
					(
						SELECT DISTINCT ID_ID_DISTR, ID_ID_PERIOD, SYS_ORDER
						FROM
							dbo.IncomeDistrTable b INNER JOIN
							dbo.IncomeTable a ON IN_ID = ID_ID_INCOME INNER JOIN
							dbo.DistrView c WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR INNER JOIN
							#distr d ON d.DIS_ID = c.DIS_ID
						WHERE
							IN_ID_CLIENT = @clientid
							AND SYS_ID_SO = @soid
					) AS o_O INNER JOIN
					dbo.PeriodTable ON PR_ID = ID_ID_PERIOD
				WHERE (
						SELECT SUM(ID_PRICE)
						FROM
							dbo.IncomeTable z INNER JOIN
							dbo.IncomeDistrTable y ON z.IN_ID = y.ID_ID_INCOME
						WHERE y.ID_ID_PERIOD =  o_O.ID_ID_PERIOD
							AND y.ID_ID_DISTR = o_O.ID_ID_DISTR
					) < 0
				ORDER BY PR_DATE, SYS_ORDER


			DECLARE @i INT
			SET @i = 0

			SET @z = 1

			WHILE @pricesum > 0
			BEGIN
				SET @z = @z + 1
				IF @z > 1000
					BREAK
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
				SET ID_PRICE = -ID_PRICE
				WHERE ID_ID = @i

				UPDATE #temp
				SET PAYED = 1
				WHERE ID_ID = @i

				--SELECT * FROM #temp

				IF @pricesum <= 0
				BEGIN
					UPDATE #temp
					SET ID_PRICE = @pricesum + ID_PRICE
					WHERE ID_ID = @i


					--DELETE FROM #temp WHERE ID_ID > @i

					SET @pricesum = 0

					--SELECT * FROM #temp
				END
			END

			DELETE FROM #temp WHERE ID_ID > @i
		END

		DELETE FROM #distr

		IF @distr IS NOT NULL
			INSERT INTO #distr
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@distr, ',')
		ELSE
			INSERT INTO #distr
				SELECT DIS_ID
				FROM dbo.ClientDistrView
				WHERE DSS_REPORT = ISNULL(@report, DSS_REPORT)
					AND CD_ID_CLIENT =
						(
							SELECT IN_ID_CLIENT
							FROM dbo.IncomeTable
							WHERE IN_ID = @incomeid
						)
				UNION

				SELECT a.DIS_ID
				FROM
					dbo.DistrView a WITH(NOEXPAND) INNER JOIN
					dbo.DistrView b WITH(NOEXPAND) ON a.DIS_NUM = b.DIS_NUM
								AND a.DIS_COMP_NUM = b.DIS_COMP_NUM
								AND a.HST_ID = b.HST_ID INNER JOIN
					dbo.ClientDistrView c ON c.DIS_ID = b.DIS_ID
				WHERE CD_ID_CLIENT =
						(
							SELECT IN_ID_CLIENT
							FROM dbo.IncomeTable
							WHERE IN_ID = @incomeid
						)


		-- разноска по уже сформированным актам (плевать, если нет счетов)
		IF (@act = 1) AND (@pricesum > 0)
		BEGIN
			IF @soid = 1
			BEGIN
				INSERT INTO #temp
					(
						ID_ID_DISTR, ID_PRICE, ID_ID_PERIOD, ID_PREPAY, PAYED, PR_DATE, SYS_ORDER
					)
					SELECT
						AD_ID_DISTR,
						AD_TOTAL_PRICE -
						ISNULL((
								SELECT SUM(ID_PRICE)
								FROM
									dbo.IncomeDistrTable INNER JOIN
									dbo.IncomeTable ON IN_ID = ID_ID_INCOME
								WHERE IN_ID_CLIENT = ACT_ID_CLIENT
									AND ID_ID_DISTR = AD_ID_DISTR
									AND ID_ID_PERIOD = AD_ID_PERIOD
							), 0) -
						ISNULL((
								SELECT SUM(ID_PRICE)
								FROM #temp
								WHERE ID_ID_DISTR = AD_ID_DISTR
									AND ID_ID_PERIOD = AD_ID_PERIOD
									AND PAYED = 1
							), 0),
						PR_ID, 0, 0, PR_DATE, SYS_ORDER
					FROM
						dbo.ActDistrTable INNER JOIN
						dbo.ActTable ON ACT_ID = AD_ID_ACT INNER JOIN
						dbo.PeriodTable ON PR_ID = AD_ID_PERIOD INNER JOIN
						dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR INNER JOIN
						#distr b ON a.DIS_ID = b.DIS_ID
					WHERE AD_TOTAL_PRICE >
						ISNULL(
							(
								SELECT SUM(ID_PRICE)
								FROM
									dbo.IncomeDistrTable INNER JOIN
									dbo.IncomeTable ON IN_ID = ID_ID_INCOME
								WHERE IN_ID_CLIENT = ACT_ID_CLIENT
									AND ID_ID_DISTR = AD_ID_DISTR
									AND ID_ID_PERIOD = AD_ID_PERIOD
							)
							, 0)
						/*
						AND NOT EXISTS
							(
								SELECT *
								FROM
									dbo.BillDistrTable INNER JOIN
									dbo.BillTable ON BL_ID = BD_ID_BILL
								WHERE BL_ID_CLIENT = ACT_ID_CLIENT
									AND BL_ID_PERIOD = AD_ID_PERIOD
									AND BD_ID_DISTR = AD_ID_DISTR
							)
						*/
						AND ACT_ID_CLIENT = @clientid
						AND SYS_ID_SO = @soid
						AND PR_DATE >=
							ISNULL
								(
									(
										SELECT PR_DATE
										FROM dbo.PeriodTable
										WHERE PR_ID = @startperiodid
									),
									(
										SELECT MIN(PR_DATE)
										FROM dbo.PeriodTable
									)
								)
					ORDER BY PR_DATE, SYS_ORDER
			END
			ELSE
			BEGIN
				INSERT INTO #temp
					(
						ID_ID_DISTR, ID_PRICE, ID_ID_PERIOD, ID_PREPAY, PAYED, PR_DATE, SYS_ORDER
					)
					SELECT
						CSD_ID_DISTR,
						CSD_TOTAL_PRICE -
						ISNULL((
								SELECT SUM(ID_PRICE)
								FROM
									dbo.IncomeDistrTable INNER JOIN
									dbo.IncomeTable ON IN_ID = ID_ID_INCOME
								WHERE IN_ID_CLIENT = CSG_ID_CLIENT
									AND ID_ID_DISTR = CSD_ID_DISTR
									AND ID_ID_PERIOD = CSD_ID_PERIOD
							), 0) -
						ISNULL((
								SELECT SUM(ID_PRICE)
								FROM #temp
								WHERE ID_ID_DISTR = CSD_ID_DISTR
									AND ID_ID_PERIOD = CSD_ID_PERIOD
									AND PAYED = 1
							), 0),
						PR_ID, 0, 0, PR_DATE, SYS_ORDER
					FROM
						dbo.ConsignmentDetailTable INNER JOIN
						dbo.ConsignmentTable ON CSG_ID = CSD_ID_CONS INNER JOIN
						dbo.PeriodTable ON PR_ID = CSD_ID_PERIOD INNER JOIN
						dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = CSD_ID_DISTR INNER JOIN
						#distr b ON a.DIS_ID = b.DIS_ID
					WHERE CSD_TOTAL_PRICE >
						ISNULL(
							(
								SELECT SUM(ID_PRICE)
								FROM
									dbo.IncomeDistrTable INNER JOIN
									dbo.IncomeTable ON IN_ID = ID_ID_INCOME
								WHERE IN_ID_CLIENT = CSG_ID_CLIENT
									AND ID_ID_DISTR = CSD_ID_DISTR
									AND ID_ID_PERIOD = CSD_ID_PERIOD
							)
							, 0)
						/*
						AND NOT EXISTS
							(
								SELECT *
								FROM
									dbo.BillDistrTable INNER JOIN
									dbo.BillTable ON BL_ID = BD_ID_BILL
								WHERE BL_ID_CLIENT = ACT_ID_CLIENT
									AND BL_ID_PERIOD = AD_ID_PERIOD
									AND BD_ID_DISTR = AD_ID_DISTR
							)
						*/
						AND CSG_ID_CLIENT = @clientid
						AND SYS_ID_SO = @soid
						AND PR_DATE >=
							ISNULL
								(
									(
										SELECT PR_DATE
										FROM dbo.PeriodTable
										WHERE PR_ID = @startperiodid
									),
									(
										SELECT MIN(PR_DATE)
										FROM dbo.PeriodTable
									)
								)
					ORDER BY PR_DATE, SYS_ORDER
			END

			SET @i = 0

			SET @z = 1

			WHILE @pricesum > 0
			BEGIN
				SET @z = @z + 1

				IF @z > 1000
					BREAK

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

				SELECT @pricesum = @pricesum - ID_PRICE
				FROM #temp
				WHERE ID_ID = @i

				UPDATE #temp
				SET PAYED = 1
				WHERE ID_ID = @i

				--SELECT * FROM #temp

				IF @pricesum <= 0
				BEGIN
					UPDATE #temp
					SET ID_PRICE = ID_PRICE + @pricesum
					WHERE ID_ID = @i

					--DELETE FROM #temp WHERE ID_ID > @i

					SET @pricesum = 0

					--SELECT * FROM #temp
				END
			END

			DELETE FROM #temp WHERE ID_ID > @i
		END

		DELETE FROM #distr
		IF @distr IS NOT NULL
			INSERT INTO #distr
				SELECT * FROM GET_TABLE_FROM_LIST(@distr, ',')
		ELSE
			INSERT INTO #distr
				SELECT DIS_ID
				FROM dbo.ClientDistrView
				WHERE CD_ID_CLIENT =
						(
							SELECT IN_ID_CLIENT
							FROM dbo.IncomeTable
							WHERE IN_ID = @incomeid
						)
					AND DSS_REPORT = @report

				UNION

				SELECT a.DIS_ID
				FROM
					dbo.DistrView a WITH(NOEXPAND) INNER JOIN
					dbo.DistrView b WITH(NOEXPAND) ON a.DIS_NUM = b.DIS_NUM
								AND a.DIS_COMP_NUM = b.DIS_COMP_NUM
								AND a.HST_ID = b.HST_ID INNER JOIN
					dbo.ClientDistrView c ON c.DIS_ID = b.DIS_ID
				WHERE CD_ID_CLIENT =
						(
							SELECT IN_ID_CLIENT
							FROM dbo.IncomeTable
							WHERE IN_ID = @incomeid
						)	AND DSS_REPORT = @report

		IF (@bill = 1) AND (@pricesum > 0) AND (EXISTS(SELECT * FROM #distr))
			AND (EXISTS(
				SELECT *
				FROM
					dbo.BillRestView
					INNER JOIN #distr ON DIS_ID = BD_ID_DISTR
				WHERE BL_ID_CLIENT = @clientid
					AND BD_REST > 0
					))
		BEGIN
			INSERT INTO #temp
				(
					ID_ID_DISTR, ID_PRICE, ID_ID_PERIOD, ID_PREPAY, PAYED, PR_DATE, SYS_ORDER
				)
				SELECT
					BD_ID_DISTR,
					BD_REST - 
					ISNULL((
							SELECT SUM(ID_PRICE)
							FROM
								#temp
							WHERE ID_ID_DISTR = BD_ID_DISTR
								AND ID_ID_PERIOD = BL_ID_PERIOD
								AND PAYED = 1
						), 0),
					PR_ID, 0, 0, PR_DATE, SYS_ORDER
				FROM
					dbo.BillRestView INNER JOIN
					dbo.PeriodTable ON PR_ID = BL_ID_PERIOD INNER JOIN
					dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR INNER JOIN
					#distr b ON a.DIS_ID = b.DIS_ID
				WHERE BD_REST > 0
					AND BL_ID_CLIENT = @clientid
					AND SYS_ID_SO = @soid
					AND PR_DATE >=
						ISNULL
							(
								(
									SELECT PR_DATE
									FROM dbo.PeriodTable
									WHERE PR_ID = @startperiodid
								),
								(
									SELECT MIN(PR_DATE)
									FROM dbo.PeriodTable
								)
							)
				ORDER BY PR_DATE, SYS_ORDER

			SET @i = 0

			SET @z = 1

			WHILE @pricesum > 0
			BEGIN
				SET @z = @z + 1

				IF @z > 1000
					BREAK
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

				SELECT @pricesum = @pricesum - ID_PRICE
				FROM #temp
				WHERE ID_ID = @i

				UPDATE #temp
				SET PAYED = 1
				WHERE ID_ID = @i

				--SELECT * FROM #temp

				IF @pricesum <= 0
				BEGIN
					UPDATE #temp
					SET ID_PRICE = ID_PRICE + @pricesum
					WHERE ID_ID = @i

					--DELETE FROM #temp WHERE ID_ID > @i

					SET @pricesum = 0

					--SELECT * FROM #temp
				END
			END

			DELETE FROM #temp WHERE ID_ID > @i
		END



		SET @z = 1

		IF (@prepay = 1) AND (@pricesum > 0) AND EXISTS (SELECT * FROM #distr)
		BEGIN
			IF @pricesum > 0
			BEGIN
				IF @bill = 1
					SELECT @prid = MAX(ID_ID_PERIOD)
					FROM #temp
				ELSE
					SET @prid = @startperiodid

				IF @prid IS NULL
				BEGIN
					SELECT TOP 1 @prid = PR_ID
					FROM
						(
							SELECT BL_ID_PERIOD
							FROM
								dbo.BillTable INNER JOIN
								dbo.BillDistrTable ON BD_ID_BILL = BL_ID INNER JOIN
								dbo.DistrView a WITH(NOEXPAND) ON a.DIS_ID = BD_ID_DISTR INNER JOIN
								#distr b ON b.DIS_ID = BD_ID_DISTR
							WHERE SYS_ID_SO = @soid
						) a INNER JOIN
						dbo.PeriodTable ON PR_ID = BL_ID_PERIOD
					ORDER BY PR_DATE DESC

					IF (@prid IS NULL) AND (@soid = 1)
					BEGIN
						SELECT TOP 1 @prid = PR_ID
						FROM
							(
								SELECT AD_ID_PERIOD
								FROM
									dbo.ActTable INNER JOIN
									dbo.ActDistrTable ON AD_ID_ACT = ACT_ID INNER JOIN
									dbo.DistrView a WITH(NOEXPAND) ON a.DIS_ID = AD_ID_DISTR INNER JOIN
									#distr b ON b.DIS_ID = AD_ID_DISTR
								WHERE SYS_ID_SO = @soid
							) a INNER JOIN
							dbo.PeriodTable ON PR_ID = AD_ID_PERIOD
						ORDER BY PR_DATE DESC
					END
					IF (@prid IS NULL) AND (@soid = 2)
					BEGIN
						SELECT TOP 1 @prid = PR_ID
						FROM
							(
								SELECT CSD_ID_PERIOD
								FROM
									dbo.ConsignmentTable INNER JOIN
									dbo.ConsignmentDetailTable ON CSD_ID_CONS = CSG_ID INNER JOIN
									dbo.DistrView a WITH(NOEXPAND) ON a.DIS_ID = CSD_ID_DISTR INNER JOIN
									#distr b ON b.DIS_ID = CSD_ID_DISTR
								WHERE SYS_ID_SO = @soid
							) a INNER JOIN
							dbo.PeriodTable ON PR_ID = CSD_ID_PERIOD
						ORDER BY PR_DATE DESC
					END
				END

				IF @prid IS NULL
					SELECT TOP 1 @prid = dbo.PERIOD_PREV(DF_ID_PERIOD)
					FROM
						dbo.DistrFinancingTable INNER JOIN
						dbo.ClientDistrTable ON CD_ID_DISTR = DF_ID_DISTR
					WHERE CD_ID_CLIENT = @clientid


				IF @prid IS NULL
				BEGIN
					SELECT @prid = PR_ID
					FROM
						dbo.PeriodTable
					WHERE PR_DATE < GETDATE() AND DATEADD(DAY, 1, PR_END_DATE) < GETDATE()
				END
				ELSE
					SET @prid = dbo.PERIOD_NEXT(@prid)

				SET @firstprid = @prid
				WHILE NOT EXISTS
					(
						SELECT *
						FROM dbo.DistrPriceView a INNER JOIN #distr b ON a.DIS_ID = b.DIS_ID
						WHERE PR_ID = @firstprid
					)
					SET @firstprid = dbo.PERIOD_PREV(@firstprid)


				WHILE (@prid IS NOT NULL) AND (@pricesum > 0) AND EXISTS (
						SELECT a.DIS_ID, DIS_TOTAL_PRICE, PR_ID, 0
						FROM
							dbo.DistrTotalPriceView a INNER JOIN
							#distr b ON a.DIS_ID = b.DIS_ID
						WHERE CD_ID_CLIENT = @clientid
							AND PR_DATE <= ISNULL((SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @prid), PR_DATE)
							AND PR_DATE >= ISNULL((SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @firstprid), PR_DATE)
							AND SO_ID = @soid
							AND NOT EXISTS
									(
										SELECT *
										FROM #temp
										WHERE ID_ID_DISTR = a.DIS_ID
											AND ID_ID_PERIOD = @prid
									)
							AND NOT EXISTS
									(
										SELECT *
										FROM
											dbo.BillTable INNER JOIN
											dbo.BillDistrTable ON BD_ID_BILL = BL_ID INNER JOIN
											dbo.DistrView WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR
										WHERE BL_ID_PERIOD = @prid
											AND BD_ID_DISTR = a.DIS_ID
											AND SYS_ID_SO = @soid
									)
					)
				BEGIN
					SET @z = @z + 1
					IF @z > 1000
						BREAK
					INSERT INTO #temp
						(
							ID_ID_DISTR, ID_PRICE, ID_ID_PERIOD, ID_PREPAY, PAYED
						)
						SELECT
							a.DIS_ID, DIS_TOTAL_PRICE -
							ISNULL((
								SELECT SUM(ID_PRICE)
								FROM
									dbo.IncomeTable INNER JOIN
									dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
								WHERE IN_ID_CLIENT = @clientid
									AND ID_ID_PERIOD = @prid
									AND ID_ID_DISTR = b.DIS_ID
							), 0) -
							ISNULL((
								SELECT SUM(ID_PRICE)
								FROM
									#temp
								WHERE ID_ID_PERIOD = @prid
									AND ID_ID_DISTR = b.DIS_ID
									AND PAYED = 1
							), 0),
							@prid, 1, 0
						FROM
							dbo.DistrTotalPriceView a INNER JOIN
							#distr b ON a.DIS_ID = b.DIS_ID
						WHERE CD_ID_CLIENT = @clientid
							AND PR_DATE <= ISNULL((SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @prid), PR_DATE)
							AND PR_DATE >= ISNULL((SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @firstprid), PR_DATE)
							AND SO_ID = @soid
							AND NOT EXISTS
									(
										SELECT *
										FROM #temp
										WHERE ID_ID_DISTR = a.DIS_ID
											AND ID_ID_PERIOD = @prid
											AND PAYED = 1
									)
							AND NOT EXISTS
								(
									SELECT *
									FROM
										dbo.BillTable INNER JOIN
										dbo.BillDistrTable ON BD_ID_BILL = BL_ID
									WHERE BL_ID_PERIOD = @prid
										AND BD_ID_DISTR = a.DIS_ID
								)
						ORDER BY PR_DATE, SYS_ORDER

					--тут потенциально ошибка :-)
					DELETE
					FROM #temp
					WHERE ID_PRICE < 0

					SET @i = 0

					--SELECT * FROM #temp

					SET @y = 1

					WHILE @pricesum > 0
					BEGIN
						SET @y = @y + 1

						IF @y > 1000
							BREAK

						IF @i IS NULL
							BREAK

						--SELECT @pricesum

						SET @i =
							(
								SELECT MIN(ID_ID)
								FROM #temp
								WHERE ID_ID > @i AND PAYED = 0
							)

						SELECT @pricesum = @pricesum - ID_PRICE
						FROM #temp
						WHERE ID_ID = @i

						UPDATE #temp
						SET PAYED = 1
						WHERE ID_ID = @i

						IF @pricesum <= 0
						BEGIN
							UPDATE #temp
							SET ID_PRICE = ID_PRICE + @pricesum
							WHERE ID_ID = @i

							DELETE FROM #temp WHERE ID_ID > @i AND PAYED = 0

							SET @pricesum = 0

							SET @i = NULL
						END
					END

					SET @prid = dbo.PERIOD_NEXT(@prid)
				END
			END
		END


		SELECT DIS_ID, DIS_STR, ID_PRICE, PR_ID, b.PR_DATE, ID_PREPAY, CONVERT(BIT, 0) AS ID_ACTION
		FROM
			#temp a INNER JOIN
			dbo.PeriodTable b ON ID_ID_PERIOD = PR_ID INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR
		WHERE ID_PRICE <> 0
		ORDER BY a.PR_DATE, a.SYS_ORDER

		--SELECT @pricesum


		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INCOME_AUTO_CONVEY] TO rl_income_w;
GO
