USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_TOTAL_SELECT]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT
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

		DECLARE @PR_DATE SMALLDATETIME
		DECLARE @TX_RATE DECIMAL(8,4)

		SELECT @PR_DATE = PR_DATE, @TX_RATE = TX_TAX_RATE
		FROM dbo.PeriodTable
		CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
		WHERE PR_ID = @PR_ID

		IF EXISTS
			(
				SELECT *
				FROM Subhost.SubhostCalcReport
				WHERE SCR_ID_SUBHOST = @SH_ID
					AND SCR_ID_PERIOD = @PR_ID
			)
			SELECT
				CONVERT(BIT, 1) AS SCR_CLOSED,
				ROUND(SCR_DELIVERY_SYS, 2) AS SCR_DELIVERY_SYS, ROUND(SCR_SUPPORT, 2) AS SCR_SUPPORT, SCR_CNT, SCR_CNT_SPEC,
				ROUND(SCR_DIU, 2) AS SCR_DIU, ROUND(SCR_SUPPORT, 2) - ROUND(SCR_DIU, 2) AS SCR_TOTAL_DIU,
				ROUND(SCR_PAPPER, 2) AS SCR_PAPPER, ROUND(SCR_MARKET, 2) AS SCR_MARKET, ROUND(SCR_STUDY, 2) AS SCR_STUDY,
				ROUND(SCR_NDS10, 2) AS SCR_NDS10, ROUND(SCR_IC, 2) AS SCR_IC,
				ROUND(SCR_DELIVERY, 2) AS SCR_DELIVERY, ROUND(SCR_TRAFFIC, 2) AS SCR_TRAFFIC,
				ROUND(SCR_TOTAL_18, 2) AS SCR_TOTAL_18, ROUND(SCR_NDS_18, 2) AS SCR_NDS_18,
				CONVERT(MONEY, ROUND(SCR_NDS10 / 10, 2)) AS SCR_TAX_10, ROUND(SCR_TOTAL_NDS, 2) AS SCR_TOTAL_NDS,
				ROUND(SCR_INCOME, 2) AS SCR_INCOME, ROUND(SCR_DEBT, 2) AS SCR_DEBT, ROUND(SCR_SALDO, 2) AS SCR_SALDO,
				ROUND(SCR_PENALTY, 2) AS SCR_PENALTY, ROUND(SCR_TOTAL, 2) AS SCR_TOTAL,
				ROUND(SCR_IC, 2) AS SCR_IC_TOTAL, ROUND(SCR_IC * @TX_RATE, 2) AS SCR_IC_TAX, ROUND(SCR_IC, 2) + ROUND(SCR_IC * @TX_RATE, 2) AS SCR_IC_TOTAL_TAX
			FROM Subhost.SubhostCalcReport
			WHERE SCR_ID_SUBHOST = @SH_ID
				AND SCR_ID_PERIOD = @PR_ID
		ELSE
		BEGIN
			DECLARE @DELIVERY MONEY

			SELECT @DELIVERY = SUM(ROUND(RNS_SUM, 2))
			FROM
				(
					SELECT
						a.PR_ID,
						CONVERT(MONEY, CASE
							-- если не нужно использовать коэффициент сети - то берем сумму по прейскуранту сумму (из групп 4 и 6 - это подхосты поставка)
							-- и умножаем на 1.
							-- UNION ALL с таблицей Subhost.SubhostPriceSystemTable - потому что можно задавать исключения из основного прейскуранта (например, для РИЦ 490)
							WHEN (
											SELECT PT_COEF
											FROM
												dbo.PriceTypeTable z
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE PTS_ID_ST = SST_ID AND PT_ID_GROUP IN (4, 6)
										) = 0 THEN
										(
											SELECT PS_PRICE
											FROM
												dbo.PriceTypeTable z
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
												INNER JOIN dbo.PriceSystemTable ON PS_ID_TYPE = PT_ID
											WHERE PTS_ID_ST = SST_ID AND PT_ID_GROUP IN (4, 6)
												AND PS_ID_PERIOD = a.PR_ID AND PS_ID_SYSTEM = a.SYS_ID
												AND NOT EXISTS
													(
														SELECT *
														FROM Subhost.SubhostPriceSystemTable
														WHERE SPS_ID_PERIOD = @PR_ID
															AND SPS_ID_SYSTEM = SYS_ID
															AND SPS_ID_HOST = @SH_ID
															AND SPS_ID_TYPE = PT_ID
													)

											UNION ALL

											SELECT SPS_PRICE
											FROM
												Subhost.SubhostPriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE SPS_ID_SYSTEM = SYS_ID
												AND SPS_ID_HOST = @SH_ID
												AND SPS_ID_PERIOD = @PR_ID
												AND PT_ID_GROUP IN (4, 6)
												AND PTS_ID_ST = SST_ID
										) * 1
							-- VIP, К1, К2 - на эти типы тоже коэфициент сетевой версии не распространяется
							WHEN SST_ID IN (7, 16, 17) THEN
									(
										SELECT PS_PRICE
										FROM
											dbo.PriceTypeTable z
											INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											INNER JOIN dbo.PriceSystemTable ON PS_ID_TYPE = PT_ID
										WHERE PTS_ID_ST = SST_ID AND PT_ID_GROUP IN (4, 6)
											AND PS_ID_PERIOD = a.PR_ID AND PS_ID_SYSTEM = a.SYS_ID
											AND NOT EXISTS
												(
													SELECT *
													FROM Subhost.SubhostPriceSystemTable
													WHERE SPS_ID_PERIOD = @PR_ID
														AND SPS_ID_SYSTEM = SYS_ID
														AND SPS_ID_HOST = @SH_ID
														AND SPS_ID_TYPE = PT_ID
												)

										UNION ALL

										SELECT SPS_PRICE
										FROM
											Subhost.SubhostPriceSystemTable
											INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
											INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
										WHERE SPS_ID_SYSTEM = SYS_ID
											AND SPS_ID_HOST = @SH_ID
											AND SPS_ID_PERIOD = @PR_ID
											AND PT_ID_GROUP IN (4, 6)
											AND PTS_ID_ST = SST_ID
									) * 1
							-- для спецвыпусков только у РИЦ 490 не распространяется коэффициент
							WHEN SST_ID = 3 AND @SH_ID = 12 THEN
									(
										SELECT PS_PRICE
										FROM
											dbo.PriceTypeTable z
											INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											INNER JOIN dbo.PriceSystemTable ON PS_ID_TYPE = PT_ID
										WHERE PTS_ID_ST = SST_ID AND PT_ID_GROUP IN (4, 6)
											AND PS_ID_PERIOD = a.PR_ID AND PS_ID_SYSTEM = a.SYS_ID
											AND NOT EXISTS
												(
													SELECT *
													FROM Subhost.SubhostPriceSystemTable
													WHERE SPS_ID_PERIOD = @PR_ID
														AND SPS_ID_SYSTEM = SYS_ID
														AND SPS_ID_HOST = @SH_ID
														AND SPS_ID_TYPE = PT_ID
												)

										UNION ALL

										SELECT SPS_PRICE
										FROM
											Subhost.SubhostPriceSystemTable
											INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
											INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
										WHERE SPS_ID_SYSTEM = SYS_ID
											AND SPS_ID_HOST = @SH_ID
											AND SPS_ID_PERIOD = @PR_ID
											AND PT_ID_GROUP IN (4, 6)
											AND PTS_ID_ST = SST_ID
									) * 1
							-- дальше пошли нереально мутные замены в дистрибутивах.
							-- считается стоимость "до" и "после" и вычитается
							-- есть условие - что никакая сумма замены не может быть меньше определенного предела
							-- в функции Subhost.MinPrice. Для РИЦ 490 и остальных подхостов это разные суммы.
							-- грубо говоря, если разница в замене 10 рублей, подхост должен все равно заплатить 59 или 58.
							WHEN SYS_OLD_NAME IS NULL AND SYS_NEW_NAME IS NULL THEN
								dbo.MoneyMax((
									SELECT PS_PRICE
									FROM
										(
											SELECT PS_PRICE
											FROM
												dbo.PriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE PTS_ID_ST = SST_ID AND PS_ID_PERIOD = @PR_ID
												AND PT_ID_GROUP IN (4, 6) AND PS_ID_SYSTEM = SYS_ID
												AND NOT EXISTS
													(
														SELECT *
														FROM Subhost.SubhostPriceSystemTable
														WHERE SPS_ID_PERIOD = @PR_ID
															AND SPS_ID_SYSTEM = SYS_ID
															AND SPS_ID_HOST = @SH_ID
															AND SPS_ID_TYPE = PT_ID
													)

											UNION ALL

											SELECT SPS_PRICE
											FROM
												Subhost.SubhostPriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE SPS_ID_SYSTEM = SYS_ID
												AND SPS_ID_HOST = @SH_ID
												AND SPS_ID_PERIOD = @PR_ID
												AND PT_ID_GROUP IN (4, 6)
												AND PTS_ID_ST = SST_ID
										) AS o_O
									WHERE PS_PRICE IS NOT NULL
								) *
								CASE
									WHEN (SELECT SST_COEF FROM dbo.SystemTypeTable z WHERE z.SST_ID = a.SST_ID) = 0 THEN 1
									WHEN (
											SELECT PT_COEF
											FROM
												dbo.PriceTypeTable z
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE PTS_ID_ST = SST_ID AND PT_ID_GROUP IN (4, 6)
										) = 0 THEN 1
									WHEN SN_OLD_NAME IS NULL AND SN_NEW_NAME IS NULL THEN
										(
											SELECT SN_COEF
											FROM
												(
													SELECT
														SN_ID,
														CASE
															WHEN @PR_DATE >= '20140101' THEN
																CASE
																	WHEN @SH_ID IN (12) THEN SNCC_VALUE
																	ELSE SNCC_SUBHOST
																END
															ELSE SN_COEF
														END AS SN_COEF
													FROM
														dbo.SystemNetTable
														INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
													WHERE SNCC_ID_PERIOD = @PR_ID
												) z
											WHERE z.SN_ID = a.SN_ID
										)
									WHEN ISNULL(SN_OLD_ID, 0) <> ISNULL(SN_NEW_ID, 0) THEN
										(
											SELECT SN_COEF
											FROM (
													SELECT
														SN_ID,
														CASE
															WHEN @PR_DATE >= '20140101' THEN
																CASE
																	WHEN @SH_ID IN (12) THEN SNCC_VALUE
																	ELSE SNCC_SUBHOST
																END
															ELSE SN_COEF
														END AS SN_COEF
													FROM
														dbo.SystemNetTable
														INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
													WHERE SNCC_ID_PERIOD = @PR_ID
												) AS o_O
											WHERE SN_ID = SN_NEW_ID
										) -
										(
											SELECT SN_COEF
											FROM (
													SELECT
														SN_ID,
														CASE
															WHEN @PR_DATE >= '20140101' THEN
																CASE
																	WHEN @SH_ID IN (12) THEN SNCC_VALUE
																	ELSE SNCC_SUBHOST
																END
															ELSE SN_COEF
														END AS SN_COEF
													FROM
														dbo.SystemNetTable
														INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
													WHERE SNCC_ID_PERIOD = @PR_ID
												) AS o_O
											WHERE SN_ID = SN_OLD_ID
										)
									ELSE 0
								END, Subhost.MinPrice(@SH_ID))
							ELSE
							/*
								Замента системы.
								Берем разницу в прейскурантах
							*/	dbo.MoneyMax(
								(
									SELECT PS_PRICE
									FROM
										(
											SELECT PS_PRICE
											FROM
												dbo.PriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE PTS_ID_ST = SST_ID AND PS_ID_PERIOD = @PR_ID
												AND PT_ID_GROUP IN (4, 6) AND PS_ID_SYSTEM = SYS_NEW_ID
												AND NOT EXISTS
													(
														SELECT *
														FROM Subhost.SubhostPriceSystemTable
														WHERE SPS_ID_PERIOD = @PR_ID
															AND SPS_ID_SYSTEM = SYS_NEW_ID
															AND SPS_ID_HOST = @SH_ID
															AND SPS_ID_TYPE = PT_ID
													)

											UNION ALL

											SELECT SPS_PRICE
											FROM
												Subhost.SubhostPriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE SPS_ID_SYSTEM = SYS_NEW_ID
												AND SPS_ID_HOST = @SH_ID
												AND SPS_ID_PERIOD = @PR_ID
												AND PT_ID_GROUP IN (4, 6)
												AND PTS_ID_ST = SST_ID
										) AS o_O
									WHERE PS_PRICE IS NOT NULL
								) * 
								CASE
									WHEN (SELECT SST_COEF FROM dbo.SystemTypeTable z WHERE z.SST_ID = a.SST_ID) = 0 THEN 1
									WHEN (
											SELECT PT_COEF
											FROM
												dbo.PriceTypeTable z
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE PTS_ID_ST = SST_ID AND PT_ID_GROUP IN (4, 6)
										) = 0 THEN 1
									WHEN SN_OLD_NAME IS NULL AND SN_NEW_NAME IS NULL THEN
										(
											SELECT SN_COEF
											FROM
												(
													SELECT
														SN_ID,
														CASE
															WHEN @PR_DATE >= '20140101' THEN
																CASE
																	WHEN @SH_ID IN (12) THEN SNCC_VALUE
																	ELSE SNCC_SUBHOST
																END
															ELSE SN_COEF
														END AS SN_COEF
													FROM
														dbo.SystemNetTable
														INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
													WHERE SNCC_ID_PERIOD = @PR_ID
												) z
											WHERE z.SN_ID = a.SN_ID
										)
									WHEN ISNULL(SN_OLD_ID, 0) <> ISNULL(SN_NEW_ID, 0) THEN
										(
											SELECT SN_COEF
											FROM (
													SELECT
														SN_ID,
														CASE
															WHEN @PR_DATE >= '20140101' THEN
																CASE
																	WHEN @SH_ID IN (12) THEN SNCC_VALUE
																	ELSE SNCC_SUBHOST
																END
															ELSE SN_COEF
														END AS SN_COEF
													FROM
														dbo.SystemNetTable
														INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
													WHERE SNCC_ID_PERIOD = @PR_ID
												) AS o_O
											WHERE SN_ID = SN_NEW_ID
										)
								END
								 -
								(
									SELECT PS_PRICE
									FROM
										(
											SELECT PS_PRICE
											FROM
												dbo.PriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE PTS_ID_ST = SST_ID AND PS_ID_PERIOD = @PR_ID
												AND PT_ID_GROUP IN (4, 6) AND PS_ID_SYSTEM = SYS_OLD_ID
												AND NOT EXISTS
													(
														SELECT *
														FROM Subhost.SubhostPriceSystemTable
														WHERE SPS_ID_PERIOD = @PR_ID
															AND SPS_ID_SYSTEM = SYS_OLD_ID
															AND SPS_ID_HOST = @SH_ID
															AND SPS_ID_TYPE = PT_ID
													)

											UNION ALL

											SELECT SPS_PRICE
											FROM
												Subhost.SubhostPriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE SPS_ID_SYSTEM = SYS_OLD_ID
												AND SPS_ID_HOST = @SH_ID
												AND SPS_ID_PERIOD = @PR_ID
												AND PT_ID_GROUP IN (4, 6)
												AND PTS_ID_ST = SST_ID
										) AS o_O
									WHERE PS_PRICE IS NOT NULL
								) *
								CASE
									WHEN (SELECT SST_COEF FROM dbo.SystemTypeTable z WHERE z.SST_ID = a.SST_ID) = 0 THEN 1
									WHEN (
											SELECT PT_COEF
											FROM
												dbo.PriceTypeTable z
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE PTS_ID_ST = SST_ID AND PT_ID_GROUP IN (4, 6)
										) = 0 THEN 1
									WHEN SN_OLD_NAME IS NULL AND SN_NEW_NAME IS NULL THEN
										(
											SELECT SN_COEF
											FROM
												(
													SELECT
														SN_ID,
														CASE
															WHEN @PR_DATE >= '20140101' THEN
																CASE
																	WHEN @SH_ID IN (12) THEN SNCC_VALUE
																	ELSE SNCC_SUBHOST
																END
															ELSE SN_COEF
														END AS SN_COEF
													FROM
														dbo.SystemNetTable
														INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
													WHERE SNCC_ID_PERIOD = @PR_ID
												) z
											WHERE z.SN_ID = a.SN_ID
										)
									WHEN ISNULL(SN_OLD_ID, 0) <> ISNULL(SN_NEW_ID, 0) THEN
										(
											SELECT SN_COEF
											FROM (
													SELECT
														SN_ID,
														CASE
															WHEN @PR_DATE >= '20140101' THEN
																CASE
																	WHEN @SH_ID IN (12) THEN SNCC_VALUE
																	ELSE SNCC_SUBHOST
																END
															ELSE SN_COEF
														END AS SN_COEF
													FROM
														dbo.SystemNetTable
														INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
													WHERE SNCC_ID_PERIOD = @PR_ID
												) AS o_O
											WHERE SN_ID = SN_OLD_ID
										)
								END, Subhost.MinPrice(@SH_ID))
						END) AS RNS_SUM
					FROM
						(
							SELECT
								RNS_ID, SH_ID, SH_SHORT_NAME, PR_ID, PR_DATE,
								SYS_ID, SYS_SHORT_NAME, SYS_ORDER,
								b.SST_ID_DHOST AS SST_ID, a.SST_CAPTION, SN_ID, SN_NAME,
								RNS_DISTR, RNS_COMP, RNS_COMMENT, DIS_STR,
								SYS_OLD_ID, SYS_OLD_NAME, SYS_NEW_ID, SYS_NEW_NAME,
								SN_OLD_ID, SN_OLD_NAME, SN_NEW_ID, SN_NEW_NAME
							FROM
								Subhost.RegNodeSubhostView a
								INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID
							WHERE SH_ID = @SH_ID AND a.PR_ID = @PR_ID
						) AS a
				) AS o_O


			IF OBJECT_ID('tempdb..#support') IS NOT NULL
				DROP TABLE #support

			CREATE TABLE #support
				(
					SST_CAPTION	VARCHAR(50),
					CNT	INT,
					PRICE	MONEY
				)

			IF OBJECT_ID('tempdb..#sup_list') IS NOT NULL
				DROP TABLE #sup_list

			CREATE TABLE #sup_list
				(
					SST_ID	INT,
					SYS_SHORT_NAME	VARCHAR(50),
					TITLE VARCHAR(50),
					SYS_COUNT	INT
				)

			IF OBJECT_ID('tempdb..#con_list') IS NOT NULL
				DROP TABLE #con_list

			CREATE TABLE #con_list
				(
					SST_ID	INT,
					SYS_SHORT_NAME	VARCHAR(50),
					TITLE VARCHAR(50),
					SYS_COUNT	INT
				)

			IF OBJECT_ID('tempdb..#comp_list') IS NOT NULL
				DROP TABLE #comp_list

			CREATE TABLE #comp_list
				(
					SST_ID	INT,
					SYS_SHORT_NAME	VARCHAR(50),
					TITLE VARCHAR(50),
					SYS_COUNT	INT
				)

			INSERT INTO #sup_list
				EXEC Subhost.SUBHOST_SUPPORT_SELECT @PR_ID, @SH_ID

			INSERT INTO #con_list
				EXEC Subhost.SUBHOST_SUPPORT_CONNECT_SELECT @PR_ID, @SH_ID

			INSERT INTO #comp_list
				EXEC Subhost.SUBHOST_SUPPORT_COMPENSATION_SELECT @PR_ID, @SH_ID


			INSERT INTO #support(SST_CAPTION, CNT, PRICE)
				SELECT SST_CAPTION, SYS_CNT, SUM(ROUND(SUMMA, 2))
				FROM
				(
				SELECT  SST_CAPTION,
						(
							SELECT SUM(SYS_COUNT)
							FROM #sup_list z
							WHERE z.SST_ID = ttl.SST_ID
						) AS SYS_CNT,
						CONVERT(MONEY,
						ROUND(SYS_COUNT *
							PS_PRICE *
							CASE
								WHEN (@PR_ID = 253 OR @PR_ID = 256) AND SST_CAPTION = 'Спец. выпуск' THEN 1
								ELSE
									CASE SST_KBU
										WHEN 1 THEN SHC_KBU
										ELSE 1
									END
							END *
							CASE SST_COEF
								WHEN 1 THEN SN_COEF
								ELSE 1
							END, 2)
						) AS SUMMA
				FROM
					(
						SELECT
							SST_CAPTION, SST_ID,
							SUM(SYS_COUNT) AS SYS_COUNT,
							SST_KBU,
							SHC_KBU,
							SST_COEF,
							SN_COEF, PS_PRICE--, SN_NAME

				FROM
					(
						SELECT SYS_SHORT_NAME, SST_ID, SST_KBU, SST_CAPTION, SUM(SYS_COUNT) AS SYS_COUNT, TITLE, SST_COEF
						FROM
							(
								SELECT
									SYS_SHORT_NAME, a.SST_ID, SST_KBU, SST_CAPTION, SYS_COUNT, TITLE, SST_COEF
								FROM
									#sup_list a
									INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID

								UNION ALL

								SELECT
									SYS_SHORT_NAME, a.SST_ID, SST_KBU, SST_CAPTION, SYS_COUNT, TITLE, SST_COEF
								FROM
									#con_list a
									INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID

								UNION ALL

								SELECT
									SYS_SHORT_NAME, a.SST_ID, SST_KBU, SST_CAPTION, -SYS_COUNT, TITLE, SST_COEF
								FROM
									#comp_list a
									INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID
							) AS dt
						GROUP BY SYS_SHORT_NAME, SST_ID, SST_KBU, SST_CAPTION, TITLE, SST_COEF
					) AS o_O
					INNER JOIN dbo.SystemTable c ON c.SYS_SHORT_NAME = o_O.SYS_SHORT_NAME
					INNER JOIN
								(
									SELECT PS_ID_SYSTEM, PTS_ID_PT, PTS_ID_ST, PS_PRICE, PS_ID_PERIOD, PS_ID_TYPE
									FROM
										dbo.PriceTypeSystemTable
										INNER JOIN dbo.PriceSystemTable ON PTS_ID_PT = PS_ID_TYPE
									WHERE NOT EXISTS
										(
											SELECT *
											FROM Subhost.SubhostPriceSystemTable
											WHERE SPS_ID_PERIOD = @PR_ID
												AND SPS_ID_HOST = @SH_ID
												AND SPS_ID_SYSTEM = PS_ID_SYSTEM
												AND SPS_ID_TYPE = PTS_ID_PT
										)

									UNION ALL

									SELECT SPS_ID_SYSTEM, PTS_ID_PT, PTS_ID_ST, SPS_PRICE, SPS_ID_PERIOD, SPS_ID_TYPE
									FROM
										dbo.PriceTypeSystemTable
										INNER JOIN Subhost.SubhostPriceSystemTable ON PTS_ID_PT = SPS_ID_TYPE AND SPS_ID_TYPE = PTS_ID_PT
									WHERE SPS_ID_PERIOD = @PR_ID
										AND SPS_ID_HOST = @SH_ID

								) d ON PTS_ID_ST = o_O.SST_ID AND d.PS_ID_SYSTEM = c.SYS_ID
							INNER JOIN dbo.PriceTypeTable e ON PTS_ID_PT = PT_ID AND PT_ID = PS_ID_TYPE
							INNER JOIN
									(
										SELECT
											SN_NAME,
											CASE
												WHEN @PR_DATE >= '20140101' THEN
													CASE
														WHEN @SH_ID IN (12) THEN SNCC_VALUE
														ELSE SNCC_SUBHOST
													END
												ELSE SN_COEF
											END AS SN_COEF
										FROM
											dbo.SystemNetTable
											INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
										WHERE SNCC_ID_PERIOD = @PR_ID
									) AS trtr ON TITLE = SN_NAME
					INNER JOIN
					(
						SELECT SYS_ID, SHC_KBU
						FROM
							dbo.SystemTable
							CROSS JOIN Subhost.SubhostCalc
						WHERE SHC_ID_SUBHOST = @SH_ID AND SHC_ID_PERIOD = @PR_ID
							AND NOT EXISTS
							(
								SELECT *
								FROM Subhost.SubhostKBUTable
								WHERE SK_ID_PERIOD = @PR_ID
									AND SK_ID_HOST = @SH_ID
									AND SK_ID_SYSTEM = SYS_ID
							)

						UNION ALL

						SELECT SK_ID_SYSTEM, SK_KBU
						FROM Subhost.SubhostKBUTable
						WHERE SK_ID_HOST = @SH_ID
							AND SK_ID_PERIOD = @PR_ID

					) AS ttt ON ttt.SYS_ID = PS_ID_SYSTEM
				WHERE PS_ID_PERIOD = @PR_ID
					AND PT_ID_GROUP IN (5, 7)
				GROUP BY SST_CAPTION, SST_ID,
						o_O.SYS_SHORT_NAME,
						SST_KBU,
						SHC_KBU,
						SST_COEF,
						SN_COEF, PS_PRICE, CASE SST_COEF WHEN 1 THEN SN_NAME ELSE '' END
				) AS TTL

				) AS tmp
			GROUP BY SST_CAPTION, SYS_CNT

		IF OBJECT_ID('tempdb..#product') IS NOT NULL
			DROP TABLE #product

		CREATE TABLE #product
			(
				SP_ID_GROUP	SMALLINT,
				SP_SUM		MONEY
			)

		INSERT INTO #product
			(SP_ID_GROUP, SP_SUM)
			SELECT
				SP_ID_GROUP,
				SUM(CONVERT(MONEY, ROUND(SPC_COUNT *
					ROUND(SPP_PRICE * (1 + ISNULL(SP_COEF, 0)/100), 2), 2)
				))
			FROM 
				Subhost.SubhostProductCalc
				INNER JOIN Subhost.SubhostProduct ON SP_ID = SPC_ID_PROD
				INNER JOIN Subhost.SubhostProductPrice ON SPP_ID_PRODUCT = SP_ID
													AND SPP_ID_PERIOD = @PR_ID
			WHERE SPC_ID_SUBHOST = @SH_ID AND SPC_ID_PERIOD = @PR_ID
			GROUP BY SP_ID_GROUP

		IF OBJECT_ID('tempdb..#pay') IS NOT NULL
			DROP TABLE #pay

		CREATE TABLE #pay
			(
				SHP_SUM	MONEY,
				SHP_DEBT	MONEY,
				SHP_PENALTY	MONEY,
				SHP_PERCENT	DECIMAL(10, 4),
				SHP_DAYS	SMALLINT
			)

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		CREATE TABLE #tmp
			(
				SHP_DATE	INT,
				SHP_SUM		MONEY,
				SHP_SUM_PREV	MONEY,
				SHP_DEBT_OLD	MONEY,
				SHP_DEBT		MONEY,
				SHP_PENALTY		MONEY,
				SHP_PERCENT		DECIMAL(8, 4),
				SHP_DAYS	INT
			)

		INSERT INTO #tmp
			EXEC Subhost.SUBHOST_SUM_SELECT @SH_ID, @PR_ID, 'SERVICE'

		INSERT INTO #pay
			SELECT SHP_SUM_PREV, SHP_DEBT, SHP_PENALTY, SHP_PERCENT, SHP_DAYS
			FROM #tmp

		--SELECT * FROM #pay

		IF OBJECT_ID('tempdb..#tmp_study') IS NOT NULL
			DROP TABLE #tmp_study

		CREATE TABLE #tmp_study
			(
				SHP_DATE	INT,
				SHP_SUM		MONEY,
				SHP_SUM_PREV	MONEY,
				SHP_DEBT_OLD	MONEY,
				SHP_DEBT		MONEY,
				SHP_PENALTY		MONEY,
				SHP_PERCENT		DECIMAL(8, 4),
				SHP_DAYS	INT
			)

		INSERT INTO #tmp_study
			EXEC Subhost.SUBHOST_SUM_SELECT @SH_ID, @PR_ID, 'STUDY'

		SELECT
			CONVERT(BIT, 0) AS SCR_CLOSED,
			SCR_DELIVERY_SYS, SCR_SUPPORT, SCR_CNT, SCR_CNT_SPEC, SCR_DIU, SCR_TOTAL_DIU,
			SCR_PAPPER, SCR_MARKET, SCR_STUDY, SCR_NDS10, SCR_IC, SCR_DELIVERY, SCR_TRAFFIC,
			SCR_TOTAL_18, SCR_NDS_18,
			SCR_DIU + SCR_TOTAL_18 + SCR_NDS_18 + SCR_NDS10 + CONVERT(MONEY, ROUND(SCR_NDS10 / 10, 2)) AS SCR_TOTAL_NDS,
			SCR_INCOME, SCR_DEBT, SCR_SALDO, SCR_PENALTY,
			SCR_DEBT + SCR_PENALTY + SCR_DIU + SCR_TOTAL_18 + SCR_NDS_18 + SCR_NDS10 + CONVERT(MONEY, ROUND(SCR_NDS10 / 10, 2)) AS SCR_TOTAL, CONVERT(MONEY, ROUND(SCR_NDS10 / 10, 2)) AS SCR_TAX_10,
			SCR_IC AS SCR_IC_TOTAL, ROUND(SCR_IC * @TX_RATE, 2) AS SCR_IC_TAX, SCR_IC + ROUND(SCR_IC * @TX_RATE, 2) AS SCR_IC_TOTAL_TAX
		FROM
			(
				SELECT
					SCR_DELIVERY_SYS, SCR_SUPPORT, SCR_CNT, SCR_CNT_SPEC, SCR_DIU, SCR_SUPPORT - SCR_DIU AS SCR_TOTAL_DIU,
					SCR_PAPPER, SCR_MARKET, SCR_STUDY, SCR_NDS10, SCR_IC,
					SCR_DELIVERY, SCR_TRAFFIC,
						SCR_TRAFFIC + SCR_DELIVERY - (SCR_IC /*+ (SELECT SHP_DEBT / 1.18 FROM #tmp_study)*/) + SCR_MARKET + SCR_STUDY + SCR_PAPPER +
						SCR_DELIVERY_SYS + SCR_SUPPORT - SCR_DIU AS SCR_TOTAL_18,
					CONVERT(MONEY, ROUND((SCR_TRAFFIC + SCR_DELIVERY - (SCR_IC  /*+ (SELECT SHP_DEBT / 1.18 FROM #tmp_study)*/) + SCR_MARKET + SCR_STUDY + SCR_PAPPER +
						SCR_DELIVERY_SYS + SCR_SUPPORT - SCR_DIU) * @TX_RATE, 2)) AS SCR_NDS_18, 
					SCR_INCOME, SCR_DEBT, SCR_SALDO, SCR_PENALTY
				FROM
					(
						SELECT
							ISNULL(CONVERT(MONEY, ROUND(SHC_PAPPER_COUNT * SHC_PAPPER_PRICE, 2)), 0) AS SCR_PAPPER,
							ISNULL(SHC_TRAFFIC, 0) AS SCR_TRAFFIC, ISNULL(SHC_DIU, 0) AS SCR_DIU, ISNULL(@DELIVERY, 0) AS SCR_DELIVERY_SYS,
							(
								SELECT SUM(CNT)
								FROM #support z
								WHERE SST_CAPTION IN ('Коммерческий', 'Серия Л')
							) AS SCR_CNT,
							(
								SELECT SUM(CNT)
								FROM #support z
								WHERE SST_CAPTION IN ('Спец. выпуск')
							) AS SCR_CNT_SPEC,
							ISNULL((
								SELECT SUM(PRICE)
								FROM #support z
							), 0) AS SCR_SUPPORT,
							ISNULL((
								SELECT SP_SUM
								FROM #product a
								WHERE SP_ID_GROUP = 1
							), 0) AS SCR_NDS10,
							ISNULL((
								SELECT SP_SUM
								FROM #product a
								WHERE SP_ID_GROUP = 2
							), 0) AS SCR_STUDY,
							ISNULL((
								SELECT SP_SUM
								FROM #product a
								WHERE SP_ID_GROUP = 3
							), 0) AS SCR_MARKET,
							(ISNULL((
								SELECT CONVERT(MONEY, SUM(ROUND(SS_COUNT * SLP_PRICE, 2)))
								FROM
									Subhost.SubhostStudy
									INNER JOIN Subhost.SubhostLessonPrice ON SLP_ID_PERIOD = SS_ID_PERIOD
																AND SLP_ID_LESSON = SS_ID_LESSON
								WHERE SS_ID_PERIOD = @PR_ID
									AND SS_ID_SUBHOST = @SH_ID
							), 0)) * CASE ISNULL(SH_CALC_STUDY, 0) WHEN 0 THEN 0 ELSE 1 END AS SCR_IC,
							ISNULL(SHC_DELIVERY, 0) AS SCR_DELIVERY,

							d.SHP_SUM AS SCR_INCOME, SHP_DEBT AS SCR_DEBT, 0 AS SCR_SALDO,
							/*CASE
								WHEN SHP_DEBT <0 THEN 0
								ELSE ROUND(SHP_DEBT * SHP_PERCENT / 100 * SHP_DAYS, 2)
							END*/
							SHP_PENALTY AS  SCR_PENALTY
						FROM
							Subhost.SubhostCalc 
							INNER JOIN dbo.SubhostTable z ON z.SH_ID = SHC_ID_SUBHOST
							LEFT OUTER JOIN #pay d ON 1 = 1
						WHERE SHC_ID_SUBHOST = @SH_ID AND SHC_ID_PERIOD = @PR_ID
					) AS o_O
			) AS  o_O

		IF OBJECT_ID('tempdb..#support') IS NOT NULL
			DROP TABLE #support

		IF OBJECT_ID('tempdb..#sup_list') IS NOT NULL
			DROP TABLE #sup_list

		IF OBJECT_ID('tempdb..#con_list') IS NOT NULL
			DROP TABLE #con_list

		IF OBJECT_ID('tempdb..#comp_list') IS NOT NULL
			DROP TABLE #comp_list

		IF OBJECT_ID('tempdb..#product') IS NOT NULL
			DROP TABLE #product

		IF OBJECT_ID('tempdb..#pay') IS NOT NULL
			DROP TABLE #pay

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		IF OBJECT_ID('tempdb..#tmp_study') IS NOT NULL
			DROP TABLE #tmp_study
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
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_TOTAL_SELECT] TO rl_subhost_calc;
GO
