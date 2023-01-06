USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[REG_NODE_SUBHOST_SELECT]
	@PR_ID	SMALLINT,
	@SH_ID	SMALLINT = NULL
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

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ID

		SELECT
			RNS_ID, SH_SHORT_NAME,
			PR_DATE,
			SYS_SHORT_NAME,
			SST_CAPTION, 
			SN_NAME,
			/*RNS_DISTR, RNS_COMP, */RNS_COMMENT,
			DIS_STR,

			CASE
				WHEN SYS_OLD_NAME IS NULL AND SYS_NEW_NAME IS NULL AND SN_OLD_NAME IS NULL AND SN_NEW_NAME IS NULL THEN 'Новая система'
				/*
				WHEN ISNULL(TT_OLD_ID, 0) < ISNULL(TT_NEW_ID, 0) THEN 
					ISNULL('c ' + SYS_OLD_NAME + ' ', 'с ') + ISNULL(ISNULL(SN_OLD_NAME, SN_NAME) + ' ', '') +
					ISNULL('на ' + SYS_NEW_NAME + ' ', 'на ') + ISNULL(TT_NEW_NAME, '')
				WHEN ISNULL(TT_OLD_ID, 0) > ISNULL(TT_NEW_ID, 0) THEN 
					ISNULL('c ' + SYS_OLD_NAME + ' ', 'с ') + ISNULL(TT_OLD_NAME, '') + ' ' +
					ISNULL('на ' + SYS_NEW_NAME + ' ', 'на ') + ISNULL(ISNULL(SN_NEW_NAME, SN_NAME), '')
				*/
				ELSE
					ISNULL('c ' + SYS_OLD_NAME + ' ', 'с ') + ISNULL(SN_OLD_NAME + ' ', '') +
					ISNULL('на ' + SYS_NEW_NAME + ' ', 'на ') + ISNULL(SN_NEW_NAME, '')
			END AS OPER,
			CONVERT(MONEY,
			CASE WHEN PR_DATE >= '20220101' AND @SH_ID NOT IN (12, 18) THEN Subhost.MinPrice(@SH_ID)
			ELSE
			CASE
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
										SELECT SN_ID,
											CASE
												WHEN PR_DATE >= '20140101' THEN
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
												WHEN PR_DATE >= '20140101' THEN
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
												WHEN PR_DATE >= '20140101' THEN
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
				*/
					dbo.MoneyMax(
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
										SELECT SN_ID,
											CASE
												WHEN PR_DATE >= '20140101' THEN
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
												WHEN PR_DATE >= '20140101' THEN
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
										SELECT SN_ID,
											CASE
												WHEN PR_DATE >= '20140101' THEN
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
												WHEN PR_DATE >= '20140101' THEN
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
			END
			END) AS RNS_SUM
			/*
			SYS_OLD_ID, SYS_OLD_NAME,
			SYS_NEW_ID, SYS_NEW_NAME,
			SN_OLD_ID, SN_OLD_NAME,
			SN_NEW_ID, SN_NEW_NAME
			*/
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
			) AS a
		WHERE PR_ID = @PR_ID AND
			(SH_ID = @SH_ID OR @SH_ID IS NULL)
		ORDER BY SH_SHORT_NAME, SYS_ORDER, SST_CAPTION, SN_NAME, RNS_DISTR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[REG_NODE_SUBHOST_SELECT] TO rl_subhost_calc;
GO
