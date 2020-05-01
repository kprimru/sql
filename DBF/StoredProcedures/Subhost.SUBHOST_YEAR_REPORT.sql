USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_YEAR_REPORT]
	@PR_MIN	SMALLINT,
	@PR_LIST	VARCHAR(MAX) = NULL
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
				TPR_ID SMALLINT PRIMARY KEY,
				TX_TOTAL_RATE DECIMAL(8, 4)
			)

		IF @PR_MIN IS NOT NULL
			INSERT INTO #period(TPR_ID, TX_TOTAL_RATE) 
				SELECT DISTINCT PR_ID, TX_TOTAL_RATE
				FROM 
					dbo.PeriodTable
					INNER JOIN Subhost.SubhostCalc ON PR_ID = SHC_ID_PERIOD
					CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
				WHERE PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_MIN)
					AND PR_DATE >= '20111101'
		ELSE
			INSERT INTO #period(TPR_ID, TX_TOTAL_RATE) 
				SELECT PR_ID, TX_TOTAL_RATE
				FROM 
					dbo.GET_TABLE_FROM_LIST(@PR_LIST, ',')
					INNER JOIN dbo.PeriodTable ON PR_ID = Item
					CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
				WHERE PR_DATE >= '20111101'

		IF OBJECT_ID('tempdb..#delivery') IS NOT NULL
			DROP TABLE #delivery

		CREATE TABLE #delivery
			(
				SH_ID	SMALLINT,
				PR_ID	SMALLINT,
				RNS_SUM	MONEY
			)

		INSERT INTO #delivery
			SELECT SH_ID, PR_ID, SUM(RNS_SUM) AS RNS_SUM
			FROM
				(
					SELECT 
						a.PR_ID,
						a.SH_ID,
						CONVERT(MONEY, CASE
						/*
							Замена только сетевитости. 
							Берем стоимость системы по прейскуранту 
							и накручиваем правильный коэффициент
						*/
							WHEN SST_ID IN (7, 16, 17) THEN 
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
													AND SPS_ID_HOST = a.SH_ID 
													AND SPS_ID_TYPE = PT_ID
											)
					
									UNION ALL
					
									SELECT SPS_PRICE
									FROM 
										Subhost.SubhostPriceSystemTable
										INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
										INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
									WHERE SPS_ID_SYSTEM = SYS_ID 
										AND SPS_ID_HOST = a.SH_ID
										AND SPS_ID_PERIOD = a.PR_ID
										AND PT_ID_GROUP IN (4, 6)
										AND PTS_ID_ST = SST_ID
									/*
									SELECT PS_PRICE
									FROM 
										dbo.PriceTypeTable z 
										INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
										INNER JOIN dbo.PriceSystemTable ON PS_ID_TYPE = PT_ID
									WHERE PTS_ID_ST = SST_ID AND PT_ID_GROUP IN (4, 6)
										AND PS_ID_PERIOD = a.PR_ID AND PS_ID_SYSTEM = a.SYS_ID
									*/
								) 
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
													AND SPS_ID_HOST = a.SH_ID 
													AND SPS_ID_TYPE = PT_ID
											)
					
									UNION ALL
					
									SELECT SPS_PRICE
									FROM 
										Subhost.SubhostPriceSystemTable
										INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
										INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
									WHERE SPS_ID_SYSTEM = SYS_ID 
										AND SPS_ID_HOST = a.SH_ID
										AND SPS_ID_PERIOD = a.PR_ID
										AND PT_ID_GROUP IN (4, 6)
										AND PTS_ID_ST = SST_ID
									/*
									SELECT PS_PRICE
									FROM 
										dbo.PriceTypeTable z 
										INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
										INNER JOIN dbo.PriceSystemTable ON PS_ID_TYPE = PT_ID
									WHERE PTS_ID_ST = SST_ID AND PT_ID_GROUP IN (4, 6)
										AND PS_ID_PERIOD = a.PR_ID AND PS_ID_SYSTEM = a.SYS_ID
									*/
								) * 1
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
															AND SPS_ID_HOST = a.SH_ID 
															AND SPS_ID_TYPE = PT_ID
													)
					
											UNION ALL
					
											SELECT SPS_PRICE
											FROM 
												Subhost.SubhostPriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE SPS_ID_SYSTEM = SYS_ID 
												AND SPS_ID_HOST = a.SH_ID
												AND SPS_ID_PERIOD = a.PR_ID
												AND PT_ID_GROUP IN (4, 6)
												AND PTS_ID_ST = SST_ID
										) AS o_O
									WHERE PS_PRICE IS NOT NULL
								) *
								CASE
									WHEN SST_ID IN (7, 16, 17) THEN 1
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
												dbo.SystemNetTable z 
											WHERE z.SN_ID = a.SN_ID 
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
								END
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
															AND SPS_ID_HOST = a.SH_ID 
															AND SPS_ID_TYPE = PT_ID
													)
					
											UNION ALL
					
											SELECT SPS_PRICE
											FROM 
												Subhost.SubhostPriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE SPS_ID_SYSTEM = SYS_NEW_ID 
												AND SPS_ID_HOST = a.SH_ID
												AND SPS_ID_PERIOD = a.PR_ID
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
												dbo.SystemNetTable z 
											WHERE z.SN_ID = a.SN_ID
										)								
									WHEN ISNULL(SN_OLD_ID, 0) <> ISNULL(SN_NEW_ID, 0) THEN
										(
											SELECT SN_COEF
											FROM dbo.SystemNetTable
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
											WHERE PTS_ID_ST = SST_ID AND PS_ID_PERIOD = a.PR_ID
												AND PT_ID_GROUP IN (4, 6) AND PS_ID_SYSTEM = SYS_OLD_ID
												AND NOT EXISTS
													(
														SELECT *
														FROM Subhost.SubhostPriceSystemTable
														WHERE SPS_ID_PERIOD = a.PR_ID
															AND SPS_ID_SYSTEM = SYS_OLD_ID 
															AND SPS_ID_HOST = a.SH_ID 
															AND SPS_ID_TYPE = PT_ID
													)
					
											UNION ALL
					
											SELECT SPS_PRICE
											FROM 
												Subhost.SubhostPriceSystemTable
												INNER JOIN dbo.PriceTypeTable ON PT_ID = SPS_ID_TYPE
												INNER JOIN dbo.PriceTypeSystemTable ON PT_ID = PTS_ID_PT
											WHERE SPS_ID_SYSTEM = SYS_OLD_ID 
												AND SPS_ID_HOST = a.SH_ID
												AND SPS_ID_PERIOD = a.PR_ID
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
												dbo.SystemNetTable z 
											WHERE z.SN_ID = a.SN_ID 
										)								
									WHEN ISNULL(SN_OLD_ID, 0) <> ISNULL(SN_NEW_ID, 0) THEN
										(
											SELECT SN_COEF
											FROM dbo.SystemNetTable
											WHERE SN_ID = SN_OLD_ID
										)
								END
						END) AS RNS_SUM				
					FROM 
						(
							SELECT 
								RNS_ID, SH_ID, SH_SHORT_NAME, PR_ID, PR_DATE, 
								SYS_ID, SYS_SHORT_NAME, SYS_ORDER, 
								a.SST_CAPTION, SN_ID, SN_NAME, RNS_DISTR, RNS_COMP, 
								RNS_COMMENT, DIS_STR, SYS_OLD_ID, SYS_OLD_NAME, 
								SYS_NEW_ID, SYS_NEW_NAME, SN_OLD_ID, SN_OLD_NAME, 
								SN_NEW_ID, SN_NEW_NAME, SST_ID_DHOST AS SST_ID
							FROM
								Subhost.RegNodeSubhostView a
								INNER JOIN #period ON TPR_ID = a.PR_ID
								INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID
						) AS a
				) AS o_O
			GROUP BY PR_ID, SH_ID

		IF OBJECT_ID('tempdb..#support') IS NOT NULL
			DROP TABLE #support

		CREATE TABLE #support
			(
				SH_ID	SMALLINT,
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
		DECLARE @SUB_ID	SMALLINT

		SELECT @PR_ID	=	MIN(TPR_ID)
		FROM #period
		

		WHILE @PR_ID IS NOT NULL
		BEGIN
			SET @SUB_ID = NULL

			SELECT @SUB_ID	=	MIN(SHC_ID_SUBHOST)
			FROM Subhost.SubhostCalc
			WHERE SHC_ID_PERIOD = @PR_ID
			
			WHILE @SUB_ID IS NOT NULL
			BEGIN
				DELETE FROM #sup_list
				INSERT INTO #sup_list
					EXEC Subhost.SUBHOST_SUPPORT_SELECT @PR_ID, @SUB_ID

				DELETE FROM #con_list
				INSERT INTO #con_list
					EXEC Subhost.SUBHOST_SUPPORT_CONNECT_SELECT @PR_ID, @SUB_ID

				DELETE FROM #comp_list
				INSERT INTO #comp_list
					EXEC Subhost.SUBHOST_SUPPORT_COMPENSATION_SELECT @PR_ID, @SUB_ID
			
				INSERT INTO #support(SH_ID, PR_ID, SST_CAPTION, CNT, PRICE)
					SELECT @SUB_ID, @PR_ID, SST_CAPTION, SYS_CNT, SUM(ROUND(SUMMA, 2))
				FROM
					(
						SELECT SST_CAPTION,
						(
							SELECT SUM(SYS_COUNT) 
							FROM #sup_list z 
							WHERE z.SST_ID = o_O.SST_ID
						) AS SYS_CNT, 
						CONVERT(MONEY,
						ROUND(SYS_COUNT *				
						--CONVERT(MONEY, 
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
					/*
					SUM(
						ROUND(SYS_COUNT * 
						PRICE * 
						CASE 
							WHEN (@PR_ID = 253 OR @PR_ID = 256) AND SST_CAPTION = 'Спец. выпуск' THEN 1
							ELSE 
								CASE SST_KBU
									WHEN 1 THEN SHC_KBU
									ELSE 1
								END
						END, 2)) AS SUMMA
					*/
				FROM
					(
						SELECT SYS_SHORT_NAME, SST_ID, SST_KBU, SST_CAPTION, SUM(ISNULL(SYS_COUNT, 0)) AS SYS_COUNT, TITLE, SST_COEF
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
												AND SPS_ID_HOST = @SUB_ID
												AND SPS_ID_SYSTEM = PS_ID_SYSTEM
												AND SPS_ID_TYPE = PTS_ID_PT
										)

									UNION ALL
		
									SELECT SPS_ID_SYSTEM, PTS_ID_PT, PTS_ID_ST, SPS_PRICE, SPS_ID_PERIOD, SPS_ID_TYPE
									FROM 
										dbo.PriceTypeSystemTable 
										INNER JOIN Subhost.SubhostPriceSystemTable ON PTS_ID_PT = SPS_ID_TYPE AND SPS_ID_TYPE = PTS_ID_PT
									WHERE SPS_ID_PERIOD = @PR_ID
										AND SPS_ID_HOST = @SUB_ID
										
								) d ON PTS_ID_ST = o_O.SST_ID AND d.PS_ID_SYSTEM = c.SYS_ID
							INNER JOIN dbo.PriceTypeTable e ON PTS_ID_PT = PT_ID AND PT_ID = PS_ID_TYPE
							INNER JOIN 
									(
										SELECT SN_NAME, SN_COEF
										FROM dbo.SystemNetTable									
									) AS trtr ON TITLE = SN_NAME
					INNER JOIN 
					(
						SELECT SYS_ID, SHC_KBU
						FROM 
							dbo.SystemTable 
							CROSS JOIN Subhost.SubhostCalc
						WHERE SHC_ID_SUBHOST = @SUB_ID AND SHC_ID_PERIOD = @PR_ID
							AND NOT EXISTS
							(
								SELECT *
								FROM Subhost.SubhostKBUTable
								WHERE SK_ID_PERIOD = @PR_ID
									AND SK_ID_HOST = @SUB_ID
									AND SK_ID_SYSTEM = SYS_ID
							)

						UNION ALL
			
						SELECT SK_ID_SYSTEM, SK_KBU
						FROM Subhost.SubhostKBUTable
						WHERE SK_ID_HOST = @SUB_ID
							AND SK_ID_PERIOD = @PR_ID
						
					) AS ttt ON ttt.SYS_ID = PS_ID_SYSTEM
				WHERE PS_ID_PERIOD = @PR_ID
					AND PT_ID_GROUP IN (5, 7)			
				) AS TTL
			GROUP BY SST_CAPTION, SYS_CNT

				SELECT @SUB_ID = MIN(SHC_ID_SUBHOST)
				FROM Subhost.SubhostCalc
				WHERE SHC_ID_PERIOD = @PR_ID AND SHC_ID_SUBHOST > @SUB_ID
			END

			SELECT @PR_ID = MIN(TPR_ID)
			FROM #period
			WHERE TPR_ID > @PR_ID
		END

		

		IF OBJECT_ID('tempdb..#product') IS NOT NULL
			DROP TABLE #product

		CREATE TABLE #product
			(
				SH_ID		SMALLINT,
				PR_ID		SMALLINT,
				SP_ID_GROUP	SMALLINT,
				SP_SUM		MONEY
			)

		INSERT INTO #product
			(SH_ID, PR_ID, SP_ID_GROUP, SP_SUM)
			SELECT 
				SPC_ID_SUBHOST, TPR_ID, SP_ID_GROUP, 
				SUM(CONVERT(MONEY, ROUND(SPC_COUNT * 
					ROUND(SPP_PRICE * (1 + ISNULL(SP_COEF, 0)/100), 2), 2)
				))
			FROM 
				#period
				INNER JOIN Subhost.SubhostProductCalc ON SPC_ID_PERIOD = TPR_ID
				INNER JOIN Subhost.SubhostProduct ON SP_ID = SPC_ID_PROD
				INNER JOIN Subhost.SubhostProductPrice ON SPP_ID_PRODUCT = SP_ID 
													AND SPP_ID_PERIOD = TPR_ID
			GROUP BY SPC_ID_SUBHOST, TPR_ID, SP_ID_GROUP
			
		IF OBJECT_ID('tempdb..#pay') IS NOT NULL
			DROP TABLE #pay

		CREATE TABLE #pay
			(
				SH_ID	SMALLINT,
				TPR_ID	SMALLINT,
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

		SELECT @PR_ID = MIN(TPR_ID)
		FROM #period

		WHILE @PR_ID IS NOT NULL
		BEGIN
			SET @SUB_ID = NULL

			SELECT @SUB_ID = MIN(SHC_ID_SUBHOST)
			FROM Subhost.SubhostCalc
			WHERE SHC_ID_PERIOD = @PR_ID

			WHILE @SUB_ID IS NOT NULL
			BEGIN
				DELETE FROM #tmp

				INSERT INTO #tmp
					EXEC Subhost.SUBHOST_SUM_SELECT @SUB_ID, @PR_ID, 'SERVICE'
			
				INSERT INTO #pay
					SELECT @SUB_ID, @PR_ID, SHP_SUM_PREV, SHP_DEBT, SHP_PENALTY, SHP_PERCENT, SHP_DAYS
					FROM #tmp

				SELECT @SUB_ID = MIN(SHC_ID_SUBHOST)
				FROM Subhost.SubhostCalc
				WHERE SHC_ID_PERIOD = @PR_ID AND SHC_ID_SUBHOST > @SUB_ID
			END
			
			SELECT @PR_ID = MIN(TPR_ID)
			FROM #period
			WHERE TPR_ID > @PR_ID
		END	
			
		--SELECT PR_ID, SH_ID, SST_CAPTION FROM #support GROUP BY PR_ID, SH_ID, SST_CAPTION HAVING COUNT(*) > 1
		--SELECT PR_ID, SH_ID, SP_ID_GROUP FROM #product GROUP BY PR_ID, SH_ID, SP_ID_GROUP HAVING COUNT(*) > 1

		SELECT
			ROW_NUMBER() OVER(PARTITION BY SH_ORDER ORDER BY SH_ORDER, PR_DATE) AS RN,
			SHC_ID_SUBHOST, SH_FULL_NAME, SH_ORDER, SHC_ID_PERIOD, PR_NAME, PR_DATE,
			DELIVERY_SUM, SUP_SUM, SUP_COM_COUNT, SUP_SPEC_COUNT,
				ISNULL(DELIVERY_SUM, 0) + 
				ISNULL(SUP_SUM, 0) + 
				ISNULL(SHC_PAPPER, 0) +
				ISNULL(SHC_DELIVERY, 0) +
				ISNULL(SHC_TRAFFIC, 0) -
				ISNULL(SHC_DIU, 0) +
				ISNULL(SP_STUDY, 0) +
				ISNULL(SP_10, 0) + 
				ISNULL(SP_MARKET, 0) - 
				ISNULL(SHP_STUDY, 0) AS TOTAL,

			CONVERT(MONEY, 
				ROUND(
						(
							ISNULL(DELIVERY_SUM, 0) + 
							ISNULL(SUP_SUM, 0) + 
							ISNULL(SHC_PAPPER, 0) +
							ISNULL(SHC_DELIVERY, 0) + 
							ISNULL(SHC_TRAFFIC, 0) -
							ISNULL(SHC_DIU, 0) +
							ISNULL(SP_STUDY, 0) +			
							ISNULL(SP_MARKET, 0) - 
							ISNULL(SHP_STUDY, 0) 
						) * TX_TOTAL_RATE, 2) + ISNULL(SHC_DIU, 0) +

			ROUND(ISNULL(SP_10, 0) * 1.1, 2)) AS TOTAL_NDS,
			(
				SELECT SHP_SUM
				FROM #pay
				WHERE TPR_ID = SHC_ID_PERIOD
					AND SH_ID = SHC_ID_SUBHOST
			) AS PAY,
			(
				SELECT SHP_DEBT
				FROM #pay
				WHERE TPR_ID = SHC_ID_PERIOD
					AND SH_ID = SHC_ID_SUBHOST
			) AS DEBT,
			(
				SELECT SHP_PENALTY
				FROM #pay
				WHERE TPR_ID = SHC_ID_PERIOD
					AND SH_ID = SHC_ID_SUBHOST
			) AS PENALTY
		FROM
			(
				SELECT 
					TX_TOTAL_RATE,
					SS_ID AS SHC_ID_SUBHOST, SH_FULL_NAME, SH_ORDER,
					a.PR_ID AS SHC_ID_PERIOD, PR_NAME, PR_DATE,
					CONVERT(MONEY, ROUND(SHC_PAPPER_COUNT * SHC_PAPPER_PRICE, 2)) AS SHC_PAPPER,
					SHC_TRAFFIC, SHC_DIU, SHC_DELIVERY,
					RNS_SUM AS DELIVERY_SUM,
					(
						SELECT SUM(CNT)
						FROM #support z
						WHERE z.PR_ID = a.PR_ID
							AND z.SH_ID = t.SH_ID
							AND SST_CAPTION IN ('Коммерческий', 'Серия Л')
					) AS SUP_COM_COUNT,
					(
						SELECT SUM(CNT)
						FROM #support z
						WHERE z.PR_ID = a.PR_ID
							AND z.SH_ID = t.SH_ID
							AND SST_CAPTION IN ('Спец. выпуск')
					) AS SUP_SPEC_COUNT,
					(
						SELECT SUM(PRICE)
						FROM #support z
						WHERE z.PR_ID = a.PR_ID
							AND z.SH_ID = t.SH_ID
					) AS SUP_SUM,
					(
						SELECT SP_SUM
						FROM #product z
						WHERE c.TPR_ID = z.PR_ID
							AND z.SH_ID = t.SH_ID
							AND SP_ID_GROUP = 1
					) AS SP_10,
					(
						SELECT SP_SUM
						FROM #product z
						WHERE c.TPR_ID = z.PR_ID
							AND z.SH_ID = t.SH_ID
							AND SP_ID_GROUP = 2
					) AS SP_STUDY,
					(
						SELECT SP_SUM
						FROM #product z
						WHERE c.TPR_ID = z.PR_ID
							AND z.SH_ID = t.SH_ID
							AND SP_ID_GROUP = 3
					) AS SP_MARKET,
					(
						SELECT CONVERT(MONEY, SUM(ROUND(SS_COUNT * SLP_PRICE, 2)))
						FROM 
							Subhost.SubhostStudy				
							INNER JOIN Subhost.SubhostLessonPrice ON SLP_ID_PERIOD = SS_ID_PERIOD 
														AND SLP_ID_LESSON = SS_ID_LESSON
						WHERE SS_ID_PERIOD = a.PR_ID
							AND SS_ID_SUBHOST = t.SH_ID
							AND SS_ID_SUBHOST = SHC_ID_SUBHOST
					) * CASE ISNULL(SH_CALC_STUDY, 0) WHEN 0 THEN 0 ELSE 1 END AS SHP_STUDY,
					SHP_SUM, SHP_DEBT, SHP_PERCENT, SHP_DAYS, SHP_PENALTY
				FROM 
					#period c 
					CROSS JOIN 
					(
						SELECT DISTINCT SHC_ID_SUBHOST AS SS_ID
						FROM 
							Subhost.SubhostCalc
							INNER JOIN #period ON TPR_ID = SHC_ID_PERIOD
					) AS dt
					LEFT OUTER JOIN Subhost.SubhostCalc ON c.TPR_ID = SHC_ID_PERIOD AND SHC_ID_SUBHOST = SS_ID
					LEFT OUTER JOIN dbo.PeriodTable a ON PR_ID = TPR_ID
					LEFT OUTER JOIN dbo.SubhostTable t ON t.SH_ID = SS_ID --SHC_ID_SUBHOST
					LEFT OUTER JOIN #delivery b ON a.PR_ID = b.PR_ID AND b.SH_ID = t.SH_ID
					LEFT OUTER JOIN #pay d ON d.TPR_ID = c.TPR_ID AND d.SH_ID = t.SH_ID
			) AS o_O
		WHERE SHC_ID_SUBHOST IS NOT NULL
		ORDER BY SH_ORDER, PR_DATE

		
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
