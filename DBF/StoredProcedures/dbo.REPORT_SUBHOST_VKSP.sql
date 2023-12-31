USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_SUBHOST_VKSP]
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

		SELECT SYS_SHORT_NAME, SYS_ORDER, SNC_SHORT, SNC_TECH * 1000 + SNC_NET_COUNT AS SNC_ORDER, SST_CAPTION, SST_ORDER, WEIGHT, COUNT(*) AS CNT, SUM(WEIGHT) AS WEIGHT_SUM
		FROM dbo.PeriodRegView a
		INNER JOIN dbo.WeightRules ON REG_ID_PERIOD = ID_PERIOD
								AND REG_ID_SYSTEM = ID_SYSTEM
								AND REG_ID_NET = ID_NET
								AND REG_ID_TYPE = ID_TYPE
		INNER JOIN dbo.SystemTypeTable ON SST_ID = REG_ID_TYPE
		--INNER JOIN dbo.SystemNetCountTable ON SNC_ID = REG_ID_NET
		WHERE REG_ID_PERIOD = @PR_ID
			AND DS_REG = 0
			AND WEIGHT <> 0
			AND REG_ID_HOST = @SH_ID
		GROUP BY SYS_SHORT_NAME, SYS_ORDER, SNC_SHORT, SNC_TECH, SNC_NET_COUNT, SST_CAPTION, SST_ORDER, REG_ID_HOST, WEIGHT
		ORDER BY SYS_ORDER, SST_ORDER, SNC_ORDER

		/*
		SELECT
			SYS_SHORT_NAME +
				CASE SYS_PROBLEM
					WHEN 0 THEN ''
					WHEN 1 THEN
						CASE REG_PROBLEM
							WHEN 1 THEN ' �����.'
							ELSE ''
						END
					WHEN 2 THEN
						CASE REG_PROBLEM
							WHEN 1 THEN ' ��2'
							ELSE ' ��2'
						END
				END AS SYS_SHORT_NAME,
			SN_NAME, SW_WEIGHT * SNCC_WEIGHT AS WEIGHT_ONE, CNT, SW_WEIGHT * SNCC_WEIGHT * CNT AS WEIGHT_SUM
		FROM
			(
				SELECT SYS_ID, SYS_SHORT_NAME, SYS_ORDER, SYS_PROBLEM, SN_NAME, SN_ORDER, SN_ID, REG_PROBLEM, COUNT(*) AS CNT
				FROM
					(
						SELECT
							SYS_ID, a.SYS_SHORT_NAME, SYS_PROBLEM, SN_NAME, SN_ORDER, SN_ID, SYS_ORDER,
							CONVERT(BIT,
								CASE
									WHEN SYS_PROBLEM = 1
										AND NOT EXISTS
										(
											SELECT *
											FROM
												dbo.PeriodRegExceptView b
												INNER JOIN dbo.DistrStatusTable ON DS_ID = b.REG_ID_STATUS
												INNER JOIN dbo.SystemProblem ON SP_ID_SYSTEM = a.REG_ID_SYSTEM
																			AND b.REG_ID_SYSTEM = SP_ID_OUT
																			AND SP_ID_PERIOD = b.REG_ID_PERIOD
											WHERE a.REG_COMPLECT = b.REG_COMPLECT
												AND a.REG_ID_PERIOD = b.REG_ID_PERIOD
												AND DS_REG = 0 AND REG_ID_TYPE <> 6
												AND a.REG_ID_SYSTEM <> b.REG_ID_SYSTEM
										) AND EXISTS
										(
											SELECT *
											FROM dbo.SystemProblem
											WHERE SP_ID_SYSTEM = a.REG_ID_SYSTEM
												AND SP_ID_PERIOD = a.REG_ID_PERIOD
										) THEN 1
									WHEN SYS_PROBLEM = 2
										AND REG_ID_TYPE = 20 THEN 1
									ELSE 0
								END) AS REG_PROBLEM
						FROM
							dbo.PeriodRegView a
							INNER JOIN
												(
													SELECT
														SYS_ID,
														CASE
															WHEN EXISTS
																(
																	SELECT * FROM dbo.SystemProblem WHERE SP_ID_SYSTEM = SYS_ID
																) THEN 1
															WHEN SYS_REG_NAME IN ('BBKZ', 'UMKZ', 'UBKZ') THEN 2
															ELSE 0
														END AS SYS_PROBLEM
													FROM dbo.SystemTable
												) AS z ON z.SYS_ID = REG_ID_SYSTEM
							INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
							INNER JOIN dbo.SystemTypeVKSP ON SSTV_ID_SST = REG_ID_TYPE
															AND SSTV_ID_PERIOD = @PR_ID
						WHERE REG_ID_HOST = @SH_ID
							AND REG_ID_PERIOD = @PR_ID
							AND DS_REG = 0
					) AS o_O
				GROUP BY SYS_ID, SYS_SHORT_NAME, SYS_ORDER, SN_NAME, SN_ORDER, REG_PROBLEM, SN_ID, SYS_PROBLEM
			) AS o_O
			INNER JOIN dbo.SystemWeightTable ON SW_ID_SYSTEM = SYS_ID
											AND SW_ID_PERIOD = @PR_ID
											AND SW_PROBLEM = REG_PROBLEM
			INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID AND SNCC_ID_PERIOD = @PR_ID
		ORDER BY SYS_ORDER, SN_ORDER
		*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_SUBHOST_VKSP] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[REPORT_SUBHOST_VKSP] TO rl_reg_report_r;
GO
