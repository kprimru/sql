USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_SUBHOST_VKSP_COMMON]
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

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		CREATE TABLE #res
			(
				SYS			NVARCHAR(256),
				SYS_ORD		INT,
				SN			NVARCHAR(128),
				SN_ORD		INT,
				SST			NVARCHAR(256),
				SST_ORDER	INT,
				WEIGHT_ONE	DECIMAL(8, 4)
			)

		IF OBJECT_ID('tempdb..#reg') IS NOT NULL
			DROP TABLE #reg

		CREATE TABLE #reg
			(
				SYS_SHORT_NAME	NVARCHAR(256),
				SYS_ORDER		INT,
				SN_NAME			NVARCHAR(256),
				SN_ORDER		INT,
				SST_NAME		VARCHAR(256),
				SST_ORDER		INT,
				REG_ID_HOST		SMALLINT,
				WEIGHT_ONE		DECIMAL(8, 4),
				CNT				SMALLINT
			)

		INSERT INTO #reg(SYS_SHORT_NAME, SYS_ORDER, SN_NAME, SN_ORDER, SST_NAME, SST_ORDER, REG_ID_HOST, WEIGHT_ONE, CNT)
			SELECT SYS_SHORT_NAME, SYS_ORDER, SNC_SHORT, SNC_TECH * 1000 + SNC_NET_COUNT, SST_CAPTION, SST_ORDER, REG_ID_HOST, WEIGHT, COUNT(*)
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
			GROUP BY SYS_SHORT_NAME, SYS_ORDER, SNC_SHORT, SNC_TECH, SNC_NET_COUNT, SST_CAPTION, SST_ORDER, REG_ID_HOST, WEIGHT
		/*
		INSERT INTO #reg(SYS_SHORT_NAME, SYS_ORDER, SN_NAME, SN_ORDER, REG_ID_HOST, WEIGHT_ONE, CNT)
			SELECT
				SYS_SHORT_NAME +
					CASE SYS_PROBLEM
						WHEN 0 THEN ''
						WHEN 1 THEN
							CASE REG_PROBLEM
								WHEN 1 THEN ' Пробл.'
								ELSE ''
							END
						WHEN 2 THEN
							CASE REG_PROBLEM
								WHEN 1 THEN ' ДЗ2/ДЗ3'
								ELSE ' ДД2'
							END
					END AS SYS_SHORT_NAME, SYS_ORDER,
				SN_NAME, SN_ORDER, REG_ID_HOST, SW_WEIGHT * SNCC_WEIGHT AS WEIGHT_ONE, CNT
			FROM
				(
					SELECT REG_ID_HOST, SYS_ID, SYS_SHORT_NAME, SYS_ORDER, SYS_PROBLEM, SN_NAME, SN_ORDER, SN_ID, REG_PROBLEM, COUNT(*) AS CNT
					FROM
						(
							SELECT
								REG_ID_HOST, SYS_ID, a.SYS_SHORT_NAME, SYS_PROBLEM, SN_NAME, SN_ORDER, SN_ID, SYS_ORDER,
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
							WHERE REG_ID_PERIOD = @PR_ID
								AND DS_REG = 0
						) AS o_O
					GROUP BY SYS_ID, SYS_SHORT_NAME, SYS_ORDER, SN_NAME, SN_ORDER, REG_PROBLEM, SN_ID, SYS_PROBLEM, REG_ID_HOST
				) AS o_O
				INNER JOIN dbo.SystemWeightTable ON SW_ID_SYSTEM = SYS_ID
												AND SW_ID_PERIOD = @PR_ID
												AND SW_PROBLEM = REG_PROBLEM
				INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID AND SNCC_ID_PERIOD = @PR_ID
			ORDER BY SYS_ORDER, SN_ORDER
		*/

		DECLARE @SUBHOST TABLE
			(
				SH_ID		SMALLINT,
				SH_SHORT	NVARCHAR(128),
				SH_ORDER	INT
			)

		INSERT INTO @SUBHOST(SH_ID, SH_SHORT, SH_ORDER)
			SELECT DISTINCT SH_ID, SH_SHORT_NAME, /*CASE SH_LST_NAME WHEN '' THEN 'Базис' ELSE SH_LST_NAME END, */SH_ORDER
			FROM
				#reg
				INNER JOIN dbo.SubhostTable ON SH_ID = REG_ID_HOST

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'ALTER TABLE #res ADD '

		SELECT @SQL = @SQL + '[' + SH_SHORT + '|Количество] INT, [' + SH_SHORT + '|Вес] DECIMAL(8, 4),'
		FROM @SUBHOST
		ORDER BY SH_ORDER

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		EXEC (@SQL)

		INSERT INTO #res (SYS, SYS_ORD, SN, SN_ORD, SST, SST_ORDER, WEIGHT_ONE)
			SELECT DISTINCT SYS_SHORT_NAME, SYS_ORDER, SN_NAME, SN_ORDER, SST_NAME, SST_ORDER, WEIGHT_ONE
			FROM #reg

		SET @SQL = 'UPDATE #res SET '

		SELECT @SQL = @SQL + '[' + SH_SHORT + '|Количество] = (SELECT CNT FROM #reg WHERE SYS_SHORT_NAME = SYS AND SN = SN_NAME AND SST = SST_NAME AND REG_ID_HOST = ' + CONVERT(VARCHAR(20), SH_ID) + '),'
		FROM @SUBHOST
		ORDER BY SH_ORDER

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		EXEC (@SQL)

		SET @SQL = 'UPDATE #res SET '

		SELECT @SQL = @SQL + '[' + SH_SHORT + '|Вес] = WEIGHT_ONE * [' + SH_SHORT + '|Количество],'
		FROM @SUBHOST
		ORDER BY SH_ORDER

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		EXEC (@SQL)

		SET @SQL = 'SELECT SYS, SN, SST, WEIGHT_ONE, '
		SELECT @SQL = @SQL + '[' + SH_SHORT + '|Количество], [' + SH_SHORT + '|Вес],'
		FROM @SUBHOST
		ORDER BY SH_ORDER

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		SET @SQL = @SQL + 'FROM #res ORDER BY SYS_ORD, SST_ORDER, SN_ORD'

		EXEC (@SQL)

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		IF OBJECT_ID('tempdb..#reg') IS NOT NULL
			DROP TABLE #reg

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[REPORT_SUBHOST_VKSP_COMMON] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[REPORT_SUBHOST_VKSP_COMMON] TO rl_reg_report_r;
GO