USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_DELIVERY_SELECT]
	@PERIOD	INT,
	@SUBHOST SMALLINT
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
		WHERE PR_ID = @PERIOD

		DECLARE @ST_GROUP VARCHAR(MAX)

		SET @ST_GROUP = ''
		SELECT @ST_GROUP = @ST_GROUP + CONVERT(VARCHAR(20), SST_ID_DHOST) + ','
		FROM
			(
				SELECT DISTINCT SST_ID_DHOST
				FROM dbo.SystemTypeTable
				WHERE SST_ID_DHOST IS NOT NULL
			) AS o_O

		IF @ST_GROUP <> ''
			SET @ST_GROUP = LEFT(@ST_GROUP, LEN(@ST_GROUP) - 1)

		IF OBJECT_ID('tempdb..#regnode') IS NOT NULL
			DROP TABLE #regnode

		CREATE TABLE #regnode
			(
				REG_ID BIGINT PRIMARY KEY,
				REG_ID_PERIOD SMALLINT,
				REG_ID_SYSTEM SMALLINT,
				REG_DISTR_NUM INT,
				REG_COMP_NUM TINYINT,
				REG_ID_TYPE SMALLINT,
				REG_ID_NET SMALLINT,
				REG_ID_OLD_SYS SMALLINT,
				REG_ID_NEW_SYS SMALLINT,
				REG_ID_OLD_NET SMALLINT,
				REG_ID_NEW_NET SMALLINT
			)

		INSERT INTO #regnode
			SELECT
				RNS_ID, RNS_ID_PERIOD, RNS_ID_SYSTEM, RNS_DISTR,
				RNS_COMP, RNS_ID_TYPE, RNS_ID_NET,
				RNS_ID_OLD_SYS, RNS_ID_NEW_SYS,
				RNS_ID_OLD_NET, RNS_ID_NEW_NET
			FROM Subhost.RegNodeSubhostTable
			WHERE RNS_ID_HOST = @SUBHOST AND RNS_ID_PERIOD = @PERIOD

		SELECT SST_ID, SYS_STR AS SYS_SHORT_NAME, NET_STR AS TITLE, COUNT(*) AS SYS_COUNT
		FROM
			(
				SELECT
					SST_ID_DHOST AS SST_ID,
					CASE
						WHEN REG_ID_OLD_SYS IS NULL AND REG_ID_NEW_SYS IS NULL THEN b.SYS_SHORT_NAME
						ELSE '� ' + e.SYS_SHORT_NAME + ' �� '  + f.SYS_SHORT_NAME
					END AS SYS_STR,
					CASE
						WHEN REG_ID_OLD_NET IS NULL AND REG_ID_NEW_NET IS NULL THEN c.SN_NAME
						ELSE
							'� ' + ISNULL(g.SN_NAME, '') + ' �� ' + ISNULL(h.SN_NAME, '')
					END NET_STR,
					SST_ORDER
				FROM
					#regnode a 
					INNER JOIN dbo.SystemTypeTable ON SST_ID = REG_ID_TYPE
					INNER JOIN dbo.GET_TABLE_FROM_LIST(@ST_GROUP, ',') ON Item = SST_ID_DHOST
					INNER JOIN dbo.SystemTable b ON b.SYS_ID = a.REG_ID_SYSTEM
					INNER JOIN
						(
							SELECT
								SN_ID, SN_NAME,
								CASE
									WHEN @PR_DATE >= '20140101' THEN
										CASE
											WHEN @SUBHOST IN (12) THEN SNCC_VALUE
											ELSE SNCC_SUBHOST
										END
									ELSE SNCC_SUBHOST
								END AS SN_COEF
							FROM
								dbo.SystemNetTable
								INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
							WHERE SNCC_ID_PERIOD = @PERIOD
						) AS c ON c.SN_ID = a.REG_ID_NET
					LEFT OUTER JOIN dbo.SystemTable e ON e.SYS_ID = a.REG_ID_OLD_SYS
					LEFT OUTER JOIN dbo.SystemTable f ON f.SYS_ID = a.REG_ID_NEW_SYS
					LEFT OUTER JOIN (
							SELECT
								SN_ID, SN_NAME,
								CASE
									WHEN @PR_DATE >= '20140101' THEN
										CASE
											WHEN @SUBHOST IN (12) THEN SNCC_VALUE
											ELSE SNCC_SUBHOST
										END
									ELSE SNCC_SUBHOST
								END AS SN_COEF
							FROM
								dbo.SystemNetTable
								INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
							WHERE SNCC_ID_PERIOD = @PERIOD
						) g ON g.SN_ID = a.REG_ID_OLD_NET
					LEFT OUTER JOIN (
							SELECT
								SN_ID, SN_NAME,
								CASE
									WHEN @PR_DATE >= '20140101' THEN
										CASE
											WHEN @SUBHOST IN (12) THEN SNCC_VALUE
											ELSE SNCC_SUBHOST
										END
									ELSE SNCC_SUBHOST
								END AS SN_COEF
							FROM
								dbo.SystemNetTable
								INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
							WHERE SNCC_ID_PERIOD = @PERIOD
						) h ON h.SN_ID = a.REG_ID_NEW_NET
			) AS o_O
		GROUP BY SST_ID, SYS_STR, NET_STR, SST_ORDER
		ORDER BY SST_ID



		IF OBJECT_ID('tempdb..#regnode') IS NOT NULL
			DROP TABLE #regnode

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_DELIVERY_SELECT] TO rl_subhost_calc;
GO
