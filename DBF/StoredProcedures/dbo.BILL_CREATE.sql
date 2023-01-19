USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[BILL_CREATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[BILL_CREATE]  AS SELECT 1')
GO
/*
Автор:			Денисов Алексей
Описание:
*/
ALTER PROCEDURE [dbo].[BILL_CREATE]
	@clientid INT,
	@periodid SMALLINT,
	@billdate SMALLDATETIME,
	@soid SMALLINT = 1,
	@fin_date BIT = 0
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

		DECLARE @billid INT

		DECLARE @moncount TINYINT
		DECLARE @prid SMALLINT

		DECLARE @TXT VARCHAR(MAX)



		--запоминаем начальный период
		SET @prid = @periodid

		--смотрим, есть ли хотя бы один дистрибутив, по которому можно выписать счет
		-- (соответствующий статус и соответствующая начальная дата)
		/*
		IF NOT EXISTS
			(
				SELECT *
				FROM
					dbo.DistrFinancingView a INNER JOIN
					dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID
				WHERE CD_ID_CLIENT = @clientid
					AND DOC_PSEDO = 'BILL'
					AND DD_PRINT = 1
					AND PR_DATE <=
						(
							SELECT PR_DATE
							FROM dbo.PeriodTable
							WHERE PR_ID = @periodid
						)
					AND DSS_REPORT = 1
					AND a.DIS_ACTIVE = 1
					AND SYS_ID_SO = @soid
			)
			RETURN
		*/

		--смотрим, на сколько месяцев клиенту нужно выставить счет
		SELECT @moncount = MAX(DF_MON_COUNT)
		FROM
			dbo.DistrFinancingTable INNER JOIN
			dbo.ClientDistrTable ON CD_ID_DISTR = DF_ID_DISTR INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
			dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
		WHERE CD_ID_CLIENT = @clientid AND SYS_ID_SO = @soid AND DSS_REPORT = 1

		IF @moncount IS NULL
			SET @moncount = 1

		SELECT @TXT = 'Клиент = "' + CL_PSEDO + '" Месяц = "' + CONVERT(VARCHAR(MAX), PR_DATE, 104) + '" Кол-во месяцев "' + CONVERT(VARCHAR(MAX), @moncount) + '"'
		FROM dbo.ClientTable, dbo.PeriodTable
		WHERE CL_ID = @clientid AND PR_ID = @periodid

		SET @TXT = ISNULL(@TXT, '')

		EXEC dbo.FINANCING_PROTOCOL_ADD 'BILL_ALL', 'Начало Формирование счета', @TXT, @clientid, NULL

		DECLARE @i TINYINT

		DECLARE @PR_DATE SMALLDATETIME

		DECLARE @RC INT

		SET @i = 0
		--по каждому месяцу пытаемся выставить счет
		WHILE @i < @moncount
			BEGIN
				SELECT @PR_DATE = PR_DATE
				FROM dbo.PeriodTable
				WHERE PR_ID = @prid

				SET @billid = NULL
				--если за месяц не было счета
				SELECT @billid = BL_ID
				FROM dbo.BillTable
				WHERE BL_ID_CLIENT = @clientid 
					AND BL_ID_PERIOD = @prid

				--если счета на указанный месяц нету, то выписываем его
				IF @billid IS NULL 
					BEGIN
						INSERT INTO dbo.BillTable(BL_ID_CLIENT, BL_ID_PERIOD, BL_ID_ORG, BL_ID_PAYER)
							SELECT @clientid, @prid, CL_ID_ORG, CL_ID_PAYER
							FROM dbo.ClientTable
							WHERE CL_ID = @clientid

						SELECT @billid = SCOPE_IDENTITY()
					END

				IF @i > 0
				BEGIN
					INSERT INTO dbo.BillDistrTable
						(
							BD_ID_BILL, BD_ID_DISTR, BD_ID_TAX,
							BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE,
							BD_DATE
						)
						SELECT
							@billid, a.DIS_ID, TX_ID,
							CASE
								WHEN @fin_date = 1 THEN
									CASE
										WHEN DF_END < @PR_DATE THEN DIS_ORIGIN
										ELSE DIS_PRICE
									END
								ELSE DIS_PRICE
							END AS DIS_PRICE,
							CAST(ROUND(CASE
								WHEN @fin_date = 1 THEN
									CASE
										WHEN DF_END < @PR_DATE THEN DIS_ORIGIN
										ELSE DIS_PRICE
									END
								ELSE DIS_PRICE
							END * ISNULL(TX_PERCENT / 100, 0), 2) AS MONEY),
							CAST(ROUND(CASE
								WHEN @fin_date = 1 THEN
									CASE
										WHEN DF_END < @PR_DATE THEN DIS_ORIGIN
										ELSE DIS_PRICE
									END
								ELSE DIS_PRICE
							END * (1 + ISNULL(TX_PERCENT/ 100, 0)), 2) AS MONEY),
							@billdate
						FROM
							dbo.DistrPriceView a INNER JOIN
							dbo.SaleObjectTable b ON a.SYS_ID_SO = b.SO_ID INNER JOIN
							dbo.TaxTable c ON c.TX_ID = b.SO_ID_TAX INNER JOIN
							dbo.DistrDocumentView d ON a.DIS_ID = d.DIS_ID
						WHERE CD_ID_CLIENT = @clientid
							AND PR_ID = @periodid
							AND SYS_ID_SO = @soid
							--проверяем, нужно ли выписывать по этому дистрибутиву счет еще на один месяц
							AND DF_MON_COUNT > @i
							AND
								(
									SELECT PR_DATE
									FROM dbo.PeriodTable
									WHERE PR_ID = DF_ID_PERIOD
								) <= @PR_DATE
							AND NOT EXISTS
									(
										--проверяем, что этого дистрибутива нет в счете
										SELECT *
										FROM dbo.BillDistrTable
										WHERE BD_ID_BILL = @billid 
											AND BD_ID_DISTR = a.DIS_ID
									)
							AND CAST(ROUND(CASE
								WHEN @fin_date = 1 THEN
									CASE
										WHEN DF_END < @PR_DATE THEN DIS_ORIGIN
										ELSE DIS_PRICE
									END
								ELSE DIS_PRICE
							END * (1 + ISNULL(TX_PERCENT/ 100, 0)), 2) AS MONEY) >
								ISNULL((
									SELECT SUM(ID_PRICE)
									FROM dbo.IncomeDistrTable INNER JOIN
										dbo.IncomeTable ON IN_ID = ID_ID_INCOME
									WHERE IN_ID_CLIENT = @clientid
										AND ID_ID_PERIOD = @periodid
										AND ID_ID_DISTR = a.DIS_ID
								), 0)
							AND DSS_REPORT = 1
							AND DIS_ACTIVE = 1
							AND DOC_PSEDO = 'BILL'
							--AND DD_PRINT = 1

					SELECT @RC = @@ROWCOUNT

					SELECT @TXT = 'Клиент = "' + CL_PSEDO + '" Месяц = "' + CONVERT(VARCHAR(MAX), @PR_DATE, 104) + '" @i = "' + CONVERT(VARCHAR(MAX), @i) + '" сфрмировано счетов = "' + CONVERT(VARCHAR(MAX), @RC) + '"'
					FROM dbo.ClientTable, dbo.PeriodTable
					WHERE CL_ID = @clientid AND PR_ID = @periodid

					SET @TXT = ISNULL(@TXT, '')

					EXEC dbo.FINANCING_PROTOCOL_ADD 'BILL_ALL', 'Формирование счета клиента', @TXT, @clientid, NULL
				END
				ELSE
				BEGIN
					INSERT INTO dbo.BillDistrTable
						(
							BD_ID_BILL, BD_ID_DISTR, BD_ID_TAX,
							BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE,
							BD_DATE
						)
						SELECT
							@billid, a.DIS_ID, TX_ID, CASE
								WHEN @fin_date = 1 THEN
									CASE
										WHEN DF_END < @PR_DATE THEN DIS_ORIGIN
										ELSE DIS_PRICE
									END
								ELSE DIS_PRICE
							END,
							CAST(ROUND(CASE
								WHEN @fin_date = 1 THEN
									CASE
										WHEN DF_END < @PR_DATE THEN DIS_ORIGIN
										ELSE DIS_PRICE
									END
								ELSE DIS_PRICE
							END * ISNULL(TX_PERCENT / 100, 0), 2) AS MONEY),
							CAST(ROUND(CASE
								WHEN @fin_date = 1 THEN
									CASE
										WHEN DF_END < @PR_DATE THEN DIS_ORIGIN
										ELSE DIS_PRICE
									END
								ELSE DIS_PRICE
							END * (1 + ISNULL(TX_PERCENT/ 100, 0)), 2) AS MONEY),
							@billdate
						FROM
							dbo.DistrPriceView a INNER JOIN
							dbo.SaleObjectTable b ON a.SYS_ID_SO = b.SO_ID INNER JOIN
							dbo.TaxTable c ON c.TX_ID = b.SO_ID_TAX INNER JOIN
							dbo.DistrDocumentView d ON a.DIS_ID = d.DIS_ID
						WHERE CD_ID_CLIENT = @clientid
							AND PR_ID = @periodid
							AND SYS_ID_SO = @soid
							--проверяем, нужно ли выписывать по этому дистрибутиву счет еще на один месяц
							AND DF_MON_COUNT > 0
							AND
								(
									SELECT PR_DATE
									FROM dbo.PeriodTable
									WHERE PR_ID = DF_ID_PERIOD
								) <= @PR_DATE
							AND NOT EXISTS
									(
										--проверяем, что этого дистрибутива нет в счете
										SELECT *
										FROM dbo.BillDistrTable
										WHERE BD_ID_BILL = @billid 
											AND BD_ID_DISTR = a.DIS_ID
									)
							/*AND CAST(ROUND(DIS_PRICE * (1 + ISNULL(TX_PERCENT/ 100, 0)), 2) AS MONEY) >
								ISNULL((
									SELECT SUM(ID_PRICE)
									FROM dbo.IncomeDistrTable INNER JOIN
										dbo.IncomeTable ON IN_ID = ID_ID_INCOME
									WHERE IN_ID_CLIENT = @clientid
										AND ID_ID_PERIOD = @periodid
										AND ID_ID_DISTR = a.DIS_ID
								), 0)*/
							AND DSS_REPORT = 1
							AND DIS_ACTIVE = 1
							AND DOC_PSEDO = 'BILL'
							--AND DD_PRINT = 1

					SELECT @RC = @@ROWCOUNT

					SELECT @TXT = 'Клиент = "' + CL_PSEDO + '" Месяц = "' + CONVERT(VARCHAR(MAX), @PR_DATE, 104) + '" @i = "' + CONVERT(VARCHAR(MAX), @i) + '" сфрмировано счетов = "' + CONVERT(VARCHAR(MAX), @RC) + '"'
					FROM dbo.ClientTable, dbo.PeriodTable
					WHERE CL_ID = @clientid AND PR_ID = @periodid

					SET @TXT = ISNULL(@TXT, '')

					EXEC dbo.FINANCING_PROTOCOL_ADD 'BILL_ALL', 'Формирование счета клиента', @TXT, @clientid, NULL
				END

				--переходим к следующему месяцу
				SET @i = @i + 1
				SET @prid = dbo.PERIOD_NEXT(@prid)
			END
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[BILL_CREATE] TO rl_bill_w;
GO
