USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[___SUBHOST_REPORT_CREATE]
	@PR_LIST	VARCHAR(MAX),
	@SH_ID	SMALLINT
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

		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		CREATE TABLE #period
			(
				TPR_ID SMALLINT PRIMARY KEY
			)

		INSERT INTO #period(TPR_ID)
			SELECT PR_ID
			FROM
				dbo.GET_TABLE_FROM_LIST(@PR_LIST, ',')
				INNER JOIN dbo.PeriodTable ON PR_ID = Item


		IF OBJECT_ID('tempdb..#delivery') IS NOT NULL
			DROP TABLE #delivery

		CREATE TABLE #delivery
			(
				PR_ID	SMALLINT,
				RNS_SUM	MONEY
			)

		INSERT INTO #delivery
			SELECT PR_ID, SUM(RNS_SUM) AS RNS_SUM
			FROM
				(
					SELECT
						a.PR_ID,
						CONVERT(MONEY, CASE
						/*
							Замена только сетевитости.
							Берем стоимость системы по прейскуранту
							и накручиваем правильный коэффициент
						*/
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
								)
							WHEN SYS_OLD_NAME IS NULL AND SYS_NEW_NAME IS NULL THEN
								(
									SELECT PS_PRICE
									FROM
										(
											SELECT PS_PRICE
											FROM
												dbo.PriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE PTS_ID_ST = SST_ID AND PS_ID_PERIOD = a.PR_ID
												AND PT_ID_GROUP IN (4, 6) AND PS_ID_SYSTEM = SYS_ID
												AND NOT EXISTS
													(
														SELECT *
														FROM Subhost.SubhostPriceSystemTable
														WHERE SPS_ID_PERIOD = a.PR_ID
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
												AND SPS_ID_PERIOD = a.PR_ID
												AND PT_ID_GROUP IN (4, 6)
												AND PTS_ID_ST = SST_ID
										) AS o_O
									WHERE PS_PRICE IS NOT NULL
								)
							ELSE
							/*
								Замента системы.
								Берем разницу в прейскурантах
							*/
								(
									SELECT PS_PRICE
									FROM
										(
											SELECT PS_PRICE
											FROM
												dbo.PriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE PTS_ID_ST = SST_ID AND PS_ID_PERIOD = a.PR_ID
												AND PT_ID_GROUP IN (4, 6) AND PS_ID_SYSTEM = SYS_NEW_ID
												AND NOT EXISTS
													(
														SELECT *
														FROM Subhost.SubhostPriceSystemTable
														WHERE SPS_ID_PERIOD = a.PR_ID
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
												AND SPS_ID_PERIOD = a.PR_ID
												AND PT_ID_GROUP IN (4, 6)
												AND PTS_ID_ST = SST_ID
										) AS o_O
									WHERE PS_PRICE IS NOT NULL
								) -
								(
									SELECT PS_PRICE
									FROM
										(
											SELECT PS_PRICE
											FROM
												dbo.PriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE PTS_ID_ST = SST_ID AND PS_ID_PERIOD = a.PR_ID
												AND PT_ID_GROUP IN (4, 6) AND PS_ID_SYSTEM = SYS_OLD_ID
												AND NOT EXISTS
													(
														SELECT *
														FROM Subhost.SubhostPriceSystemTable
														WHERE SPS_ID_PERIOD = a.PR_ID
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
												AND SPS_ID_PERIOD = a.PR_ID
												AND PT_ID_GROUP IN (4, 6)
												AND PTS_ID_ST = SST_ID
										) AS o_O
									WHERE PS_PRICE IS NOT NULL
								)
						END *
						CASE
							WHEN (SELECT SST_COEF FROM dbo.SystemTypeTable z WHERE z.SST_ID = a.SST_ID) = 0 THEN 1
							WHEN (
									SELECT PT_COEF
									FROM
										dbo.PriceTypeTable z
										INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
									WHERE PTS_ID_ST = SST_ID AND PT_ID_GROUP IN (4, 6)
								) = 0 THEN 1
							WHEN SN_OLD_NAME IS NULL AND SN_NEW_NAME IS NULL AND TT_NEW_NAME IS NULL AND TT_OLD_NAME IS NULL THEN
								(
									SELECT SN_COEF * TT_COEF
									FROM
										dbo.SystemNetTable z CROSS JOIN
										dbo.TechnolTypeTable y
									WHERE z.SN_ID = a.SN_ID AND y.TT_ID = a.TT_ID
								)
							WHEN ISNULL(TT_OLD_ID, 0) <> ISNULL(TT_NEW_ID, 0) THEN
								(
									SELECT TT_COEF
									FROM dbo.TechnolTypeTable
									WHERE TT_ID = TT_NEW_ID
								) -
								(
									SELECT TT_COEF
									FROM dbo.TechnolTypeTable
									WHERE TT_ID = TT_OLD_ID
								)
							WHEN ISNULL(SN_OLD_ID, 0) <> ISNULL(SN_NEW_ID, 0) THEN
								(
									SELECT SN_COEF
									FROM dbo.SystemNetTable
									WHERE SN_ID = SN_NEW_ID
								) -
								(
									SELECT SN_COEF
									FROM dbo.SystemNetTable
									WHERE SN_ID = SN_OLD_ID
								)
						END) AS RNS_SUM
					FROM
						Subhost.RegNodeSubhostView a
						INNER JOIN #period ON TPR_ID = a.PR_ID
					WHERE SH_ID = @SH_ID
				) AS o_O
			GROUP BY PR_ID

		IF OBJECT_ID('tempdb..#support') IS NOT NULL
			DROP TABLE #support

		CREATE TABLE #support
			(
				PR_ID	SMALLINT,
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

		DECLARE @PR_ID	SMALLINT

		SELECT @PR_ID	=	MIN(TPR_ID)
		FROM #period

		WHILE @PR_ID IS NOT NULL
		BEGIN
			DELETE FROM #sup_list
			INSERT INTO #sup_list
				EXEC Subhost.SUBHOST_SUPPORT_SELECT @PR_ID, @SH_ID

			DELETE FROM #con_list
			INSERT INTO #con_list
				EXEC Subhost.SUBHOST_SUPPORT_CONNECT_SELECT @PR_ID, @SH_ID

			DELETE FROM #comp_list
			INSERT INTO #comp_list
				EXEC Subhost.SUBHOST_SUPPORT_COMPENSATION_SELECT @PR_ID, @SH_ID

			INSERT INTO #support(PR_ID, SST_CAPTION, CNT, PRICE)
				SELECT
					@PR_ID, SST_CAPTION,
					(
						SELECT SUM(SYS_COUNT)
						FROM #sup_list z
						WHERE z.SST_ID = o_O.SST_ID
					),
					SUM(
						ROUND(SYS_COUNT *
						PRICE *
						CASE SST_KBU
							WHEN 1 THEN SHC_KBU
							ELSE 1
						END, 2)) AS SUMMA
				FROM
					(
						SELECT
							a.SST_ID, SST_KBU, SST_CAPTION, SYS_COUNT,
							PS_ID_SYSTEM,
							CONVERT(MONEY,
								PS_PRICE *
								CASE SST_COEF
									WHEN 1 THEN SN_COEF
									ELSE 1
								END
							) AS PRICE
						FROM
							#sup_list a
							INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID
							INNER JOIN dbo.SystemTable c ON c.SYS_SHORT_NAME = a.SYS_SHORT_NAME
							INNER JOIN dbo.PriceSystemTable d ON d.PS_ID_SYSTEM = c.SYS_ID
							INNER JOIN dbo.PriceTypeTable e ON PT_ID = PS_ID_TYPE
							INNER JOIN dbo.PriceTypeSystemTable ON PTS_ID_PT = PT_ID AND PTS_ID_ST = a.SST_ID
							INNER JOIN
									(
										SELECT SN_NAME, SN_COEF
										FROM dbo.SystemNetTable

										UNION ALL

										SELECT TT_NAME, TT_COEF
										FROM dbo.TechnolTypeTable
										WHERE TT_REG <> 0
									) AS o_O ON TITLE = SN_NAME
						WHERE PS_ID_PERIOD = @PR_ID
							AND PT_ID_GROUP IN (5, 7)

						UNION ALL

						SELECT
							a.SST_ID, SST_KBU, SST_CAPTION, SYS_COUNT,
							PS_ID_SYSTEM,
							CONVERT(MONEY,
								PS_PRICE *
								CASE SST_COEF
									WHEN 1 THEN SN_COEF
									ELSE 1
								END
							) AS PRICE
						FROM
							#con_list a
							INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID
							INNER JOIN dbo.SystemTable c ON c.SYS_SHORT_NAME = a.SYS_SHORT_NAME
							INNER JOIN dbo.PriceSystemTable d ON d.PS_ID_SYSTEM = c.SYS_ID
							INNER JOIN dbo.PriceTypeTable e ON PT_ID = PS_ID_TYPE
							INNER JOIN dbo.PriceTypeSystemTable ON PTS_ID_PT = PT_ID AND PTS_ID_ST = a.SST_ID
							INNER JOIN
									(
										SELECT SN_NAME, SN_COEF
										FROM dbo.SystemNetTable

										UNION ALL

										SELECT TT_NAME, TT_COEF
										FROM dbo.TechnolTypeTable
										WHERE TT_REG <> 0
									) AS o_O ON TITLE = SN_NAME
						WHERE PS_ID_PERIOD = @PR_ID
							AND PT_ID_GROUP IN (5, 7)

						UNION ALL

						SELECT
							a.SST_ID, SST_KBU, SST_CAPTION, SYS_COUNT,
							PS_ID_SYSTEM,
							CONVERT(MONEY,
								- PS_PRICE *
								CASE SST_COEF
									WHEN 1 THEN SN_COEF
									ELSE 1
								END
							) AS PRICE
						FROM
							#comp_list a
							INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID
							INNER JOIN dbo.SystemTable c ON c.SYS_SHORT_NAME = a.SYS_SHORT_NAME
							INNER JOIN dbo.PriceSystemTable d ON d.PS_ID_SYSTEM = c.SYS_ID
							INNER JOIN dbo.PriceTypeTable e ON PT_ID = PS_ID_TYPE
							INNER JOIN dbo.PriceTypeSystemTable ON PTS_ID_PT = PT_ID AND PTS_ID_ST = a.SST_ID
							INNER JOIN
									(
										SELECT SN_NAME, SN_COEF
										FROM dbo.SystemNetTable

										UNION ALL

										SELECT TT_NAME, TT_COEF
										FROM dbo.TechnolTypeTable
										WHERE TT_REG <> 0
									) AS o_O ON TITLE = SN_NAME
						WHERE PS_ID_PERIOD = @PR_ID
							AND PT_ID_GROUP IN (5, 7)
					) AS o_O
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
				GROUP BY SST_ID, SST_CAPTION

			SELECT @PR_ID = MIN(TPR_ID)
			FROM #period
			WHERE TPR_ID > @PR_ID
		END

		IF OBJECT_ID('tempdb..#product') IS NOT NULL
			DROP TABLE #product

		CREATE TABLE #product
			(
				PR_ID		SMALLINT,
				SP_ID_GROUP	SMALLINT,
				SP_SUM		MONEY
			)

		INSERT INTO #product
			(PR_ID, SP_ID_GROUP, SP_SUM)
			SELECT
				TPR_ID, SP_ID_GROUP,
				SUM(CONVERT(MONEY,
					ROUND(SPP_PRICE * SPC_COUNT * (1 + ISNULL(SP_COEF, 0)/100), 2)
				))
			FROM
				#period
				INNER JOIN Subhost.SubhostProductCalc ON SPC_ID_PERIOD = TPR_ID
				INNER JOIN Subhost.SubhostProduct ON SP_ID = SPC_ID_PROD
				INNER JOIN Subhost.SubhostProductPrice ON SPP_ID_PRODUCT = SP_ID
													AND SPP_ID_PERIOD = TPR_ID
			WHERE SPC_ID_SUBHOST = @SH_ID
			GROUP BY TPR_ID, SP_ID_GROUP

		IF OBJECT_ID('tempdb..#pay') IS NOT NULL
			DROP TABLE #pay

		CREATE TABLE #pay
			(
				TPR_ID	SMALLINT,
				SHP_SUM	MONEY,
				SHP_DEBT	MONEY,
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
				SHP_PERCENT		DECIMAL(8, 4),
				SHP_DAYS	INT
			)

		SELECT @PR_ID = MIN(TPR_ID)
		FROM #period

		WHILE @PR_ID IS NOT NULL
		BEGIN
			DELETE FROM #tmp

			INSERT INTO #tmp
				EXEC Subhost.SUBHOST_SUM_SELECT @SH_ID, @PR_ID, 'SERVICE'

			INSERT INTO #pay
				SELECT @PR_ID, SHP_SUM_PREV, SHP_DEBT, SHP_PERCENT, SHP_DAYS
				FROM #tmp

			SELECT @PR_ID = MIN(TPR_ID)
			FROM #period
			WHERE TPR_ID > @PR_ID
		END

		SELECT
			SH_SHORT_NAME, SH_ID, PR_NAME, 
			CONVERT(MONEY, ROUND(SHC_PAPPER_COUNT * SHC_PAPPER_PRICE, 2)) AS SHC_PAPPER,
			SHC_TRAFFIC, SHC_DIU, SHC_DELIVERY,
			SHC_INV_NUM, SHC_INV_DATE,
			SHC_INV_STUDY_DATE, SHC_INV_STUDY_NUM,
			RNS_SUM AS DELIVERY_SUM,
			(
				SELECT SUM(CNT)
				FROM #support z
				WHERE z.PR_ID = a.PR_ID
					AND SST_CAPTION IN ('Коммерческий', 'Серия Л')
			) AS SUP_COM_COUNT,
			(
				SELECT SUM(CNT)
				FROM #support z
				WHERE z.PR_ID = a.PR_ID
					AND SST_CAPTION IN ('Спец. выпуск')
			) AS SUP_SPEC_COUNT,
			(
				SELECT SUM(PRICE)
				FROM #support z
				WHERE z.PR_ID = a.PR_ID
			) AS SUP_SUM,
			(
				SELECT SP_SUM
				FROM #product a
				WHERE c.TPR_ID = a.PR_ID
					AND SP_ID_GROUP = 1
			) AS SP_10,
			(
				SELECT SP_SUM
				FROM #product a
				WHERE c.TPR_ID = a.PR_ID
					AND SP_ID_GROUP = 2
			) AS SP_STUDY,
			(
				SELECT SP_SUM
				FROM #product a
				WHERE c.TPR_ID = a.PR_ID
					AND SP_ID_GROUP = 3
			) AS SP_MARKET,
			(
				SELECT CONVERT(MONEY, SUM(ROUND(SS_COUNT * SLP_PRICE, 2)))
				FROM
					Subhost.SubhostStudy
					INNER JOIN Subhost.SubhostLessonPrice ON SLP_ID_PERIOD = SS_ID_PERIOD
												AND SLP_ID_LESSON = SS_ID_LESSON
				WHERE SS_ID_PERIOD = a.PR_ID
					AND SS_ID_SUBHOST = @SH_ID
			) AS SHP_STUDY,
			SHP_SUM, SHP_DEBT, SHP_PERCENT, SHP_DAYS
		FROM
			dbo.SubhostTable
			INNER JOIN Subhost.SubhostCalc ON SH_ID = SHC_ID_SUBHOST
			INNER JOIN #period c ON c.TPR_ID = SHC_ID_PERIOD
			INNER JOIN dbo.PeriodTable a ON PR_ID = TPR_ID
			LEFT OUTER JOIN #delivery b ON a.PR_ID = b.PR_ID
			LEFT OUTER JOIN #pay d ON d.TPR_ID = c.TPR_ID
		WHERE SHC_ID_SUBHOST = @SH_ID
		ORDER BY PR_DATE


		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		IF OBJECT_ID('tempdb..#delivery') IS NOT NULL
			DROP TABLE #delivery

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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
