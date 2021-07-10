USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_NET_COEF_GET]
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

		DECLARE @PR_DATE	SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ID

		IF OBJECT_ID('tempdb..#sgr') IS NOT NULL
			DROP TABLE #sgr

		CREATE TABLE #sgr
			(
				ID INT IDENTITY(1, 1) PRIMARY KEY,
				TITLE VARCHAR(100),
				SN_ID SMALLINT,
				TT_ID SMALLINT,
				--SN_SOURCE SMALLINT,
				--SN_DEST SMALLINT,
				COEF DECIMAL(8, 4),
				COEF_OLD DECIMAL(8, 4),
				COEF_NEW DECIMAL(8, 4)
			)

		IF @PR_DATE >= '20140101'
		BEGIN
			INSERT INTO #sgr(TITLE, SN_ID, COEF, COEF_OLD, COEF_NEW)
				SELECT
					SN_NAME, SN_ID, SN_COEF, SN_COEF_OLD, SN_COEF_NEW
				FROM
					(
						SELECT
							SN_NAME, SN_ID,
							CASE
								WHEN @SH_ID IN (12) THEN SNCC_VALUE
								ELSE SNCC_SUBHOST
							END AS SN_COEF,
							CASE
								WHEN @SH_ID IN (12) THEN SNCC_VALUE
								ELSE SNCC_SUBHOST
							END AS SN_COEF_OLD,
							CASE
								WHEN @SH_ID IN (12) THEN SNCC_VALUE
								ELSE SNCC_SUBHOST
							END AS SN_COEF_NEW,
							(
								SELECT MAX(SNC_NET_COUNT)
								FROM dbo.SystemNetCountTable
								WHERE SNC_ID_SN = SN_ID
							) AS NET_COUNT,
							(
								SELECT MAX(SNC_TECH)
								FROM dbo.SystemNetCountTable
								WHERE SNC_ID_SN = SN_ID
							) AS TECH_TYPE
						FROM
							dbo.SystemNetTable
							INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
						WHERE SNCC_ID_PERIOD = @PR_ID
					) AS o_O
				ORDER BY TECH_TYPE, NET_COUNT


		/*
		INSERT INTO #sgr(TITLE, COEF, COEF_OLD, COEF_NEW)
			SELECT 'с ' + a.SN_NAME + ' на ' + b.SN_NAME, b.SN_COEF - a.SN_COEF, a.SN_COEF, b.SN_COEF
			FROM
				dbo.SystemNetTable a INNER JOIN
				dbo.SystemNetTable b ON a.SN_COEF <> b.SN_COEF
			ORDER BY a.SN_ORDER, b.SN_ORDER
		*/

			INSERT INTO #sgr(TITLE, COEF, COEF_OLD, COEF_NEW)
				SELECT TITLE, COEF, COEF_OLD, COEF_NEW
				FROM
					(
						SELECT
							CASE
								WHEN REG_ID_OLD_NET IS NULL AND REG_ID_NEW_NET IS NULL THEN c.SN_NAME
								ELSE
									'с ' + ISNULL(g.SN_NAME, '') + ' на ' + ISNULL(h.SN_NAME, '')
							END AS TITLE,
							CASE
								WHEN REG_ID_OLD_NET IS NULL AND REG_ID_NEW_NET IS NULL THEN	c.SN_COEF
								ELSE
									ISNULL(h.SN_COEF, c.SN_COEF) - ISNULL(g.SN_COEF, c.SN_COEF)
							END AS COEF,
							CASE
								WHEN REG_ID_OLD_NET IS NULL AND REG_ID_NEW_NET IS NULL THEN	c.SN_COEF
								ELSE
									ISNULL(g.SN_COEF, c.SN_COEF)
							END AS COEF_OLD,
							CASE
								WHEN REG_ID_OLD_NET IS NULL AND REG_ID_NEW_NET IS NULL THEN c.SN_COEF
								ELSE
									ISNULL(h.SN_COEF, c.SN_COEF)
							END AS COEF_NEW,
							ROW_NUMBER() OVER(ORDER BY c.SN_COEF, ISNULL(g.SN_COEF, c.SN_COEF), ISNULL(h.SN_COEF, c.SN_COEF)) AS ORD
						FROM
							(
								SELECT
									RNS_ID_NET AS REG_ID_NET,
									RNS_ID_OLD_NET AS REG_ID_OLD_NET, RNS_ID_NEW_NET AS REG_ID_NEW_NET
								FROM Subhost.RegNodeSubhostTable
								WHERE RNS_ID_PERIOD = @PR_ID AND RNS_ID_HOST = @SH_ID
							) AS a
							INNER JOIN
							(
								SELECT
									SN_ID, SN_NAME,
									CASE
										WHEN @SH_ID IN (12) THEN SNCC_VALUE
										ELSE SNCC_SUBHOST
									END AS SN_COEF,
									(
										SELECT MAX(SNC_NET_COUNT)
										FROM dbo.SystemNetCountTable
										WHERE SNC_ID_SN = SN_ID
									) AS NET_COUNT,
									(
										SELECT MAX(SNC_TECH)
										FROM dbo.SystemNetCountTable
										WHERE SNC_ID_SN = SN_ID
									) AS TECH_TYPE
								FROM
									dbo.SystemNetTable
									INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
								WHERE SNCC_ID_PERIOD = @PR_ID
							) c ON c.SN_ID = a.REG_ID_NET
							LEFT OUTER JOIN (
								SELECT
									SN_ID, SN_NAME,
									CASE
										WHEN @SH_ID IN (12) THEN SNCC_VALUE
										ELSE SNCC_SUBHOST
									END AS SN_COEF,
									(
										SELECT MAX(SNC_NET_COUNT)
										FROM dbo.SystemNetCountTable
										WHERE SNC_ID_SN = SN_ID
									) AS NET_COUNT,
									(
										SELECT MAX(SNC_TECH)
										FROM dbo.SystemNetCountTable
										WHERE SNC_ID_SN = SN_ID
									) AS TECH_TYPE
								FROM
									dbo.SystemNetTable
									INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
								WHERE SNCC_ID_PERIOD = @PR_ID
							) g ON g.SN_ID = a.REG_ID_OLD_NET
							LEFT OUTER JOIN (
								SELECT
									SN_ID, SN_NAME,
									CASE
										WHEN @SH_ID IN (12) THEN SNCC_VALUE
										ELSE SNCC_SUBHOST
									END AS SN_COEF,
									(
										SELECT MAX(SNC_NET_COUNT)
										FROM dbo.SystemNetCountTable
										WHERE SNC_ID_SN = SN_ID
									) AS NET_COUNT,
									(
										SELECT MAX(SNC_TECH)
										FROM dbo.SystemNetCountTable
										WHERE SNC_ID_SN = SN_ID
									) AS TECH_TYPE
								FROM
									dbo.SystemNetTable
									INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
								WHERE SNCC_ID_PERIOD = @PR_ID
							) h ON h.SN_ID = a.REG_ID_NEW_NET
					) AS o_O
				WHERE NOT EXISTS
					(
						SELECT *
						FROM #sgr z
						WHERE z.TITLE = o_O.TITLE
					)
				ORDER BY ORD

			DELETE a
			FROM #sgr a
			WHERE EXISTS
				(
					SELECT *
					FROM #sgr b
					WHERE a.TITLE = b.TITLE
						AND a.ID > b.ID
				)
		END
		ELSE
		BEGIN
			INSERT INTO #sgr(TITLE, SN_ID, COEF, COEF_OLD, COEF_NEW)
				SELECT SN_NAME, SN_ID, SN_COEF AS SN_COEF_O, SN_COEF, SN_COEF
				FROM dbo.SystemNetTable
				ORDER BY SN_COEF_O


		/*
		INSERT INTO #sgr(TITLE, COEF, COEF_OLD, COEF_NEW)
			SELECT 'с ' + a.SN_NAME + ' на ' + b.SN_NAME, b.SN_COEF - a.SN_COEF, a.SN_COEF, b.SN_COEF
			FROM
				dbo.SystemNetTable a INNER JOIN
				dbo.SystemNetTable b ON a.SN_COEF <> b.SN_COEF
			ORDER BY a.SN_ORDER, b.SN_ORDER
		*/


			INSERT INTO #sgr(TITLE, COEF, COEF_OLD, COEF_NEW)
				SELECT TITLE, COEF, COEF_OLD, COEF_NEW
				FROM
					(
						SELECT
							CASE
								WHEN REG_ID_OLD_NET IS NULL AND REG_ID_NEW_NET IS NULL THEN c.SN_NAME
								ELSE
									'с ' + ISNULL(g.SN_NAME, '') + ' на ' + ISNULL(h.SN_NAME, '')
							END AS TITLE,
							CASE
								WHEN REG_ID_OLD_NET IS NULL AND REG_ID_NEW_NET IS NULL THEN c.SN_COEF
								ELSE
									ISNULL(h.SN_COEF, c.SN_COEF) - ISNULL(g.SN_COEF, c.SN_COEF)
							END AS COEF,
							CASE
								WHEN REG_ID_OLD_NET IS NULL AND REG_ID_NEW_NET IS NULL THEN c.SN_COEF
								ELSE
									ISNULL(g.SN_COEF, c.SN_COEF)
							END AS COEF_OLD,
							CASE
								WHEN REG_ID_OLD_NET IS NULL AND REG_ID_NEW_NET IS NULL THEN
									c.SN_COEF
								ELSE
									ISNULL(h.SN_COEF, c.SN_COEF)
							END AS COEF_NEW,
							ROW_NUMBER() OVER(ORDER BY c.SN_COEF, ISNULL(g.SN_COEF, c.SN_COEF), ISNULL(h.SN_COEF, c.SN_COEF)) AS ORD
						FROM
							(
								SELECT
									RNS_ID_NET AS REG_ID_NET,
									RNS_ID_OLD_NET AS REG_ID_OLD_NET, RNS_ID_NEW_NET AS REG_ID_NEW_NET
								FROM Subhost.RegNodeSubhostTable
								WHERE RNS_ID_PERIOD = @PR_ID AND RNS_ID_HOST = @SH_ID
							) AS a
							INNER JOIN dbo.SystemNetTable c ON c.SN_ID = a.REG_ID_NET
							LEFT OUTER JOIN dbo.SystemNetTable g ON g.SN_ID = a.REG_ID_OLD_NET
							LEFT OUTER JOIN dbo.SystemNetTable h ON h.SN_ID = a.REG_ID_NEW_NET
					) AS o_O
				WHERE NOT EXISTS
					(
						SELECT *
						FROM #sgr z
						WHERE z.TITLE = o_O.TITLE
					)
				ORDER BY ORD

			DELETE a
			FROM #sgr a
			WHERE EXISTS
				(
					SELECT *
					FROM #sgr b
					WHERE a.TITLE = b.TITLE
						AND a.ID > b.ID
				)
		END


		UPDATE #sgr
		SET COEF = 0,
			COEF_OLD = 1.25,
			COEF_NEW = 1.25
		WHERE TITLE = 'с 1/с на ОВМ ОД 1'

		UPDATE #sgr
		SET COEF = 0,
			COEF_OLD = 1,
			COEF_NEW = 1.25
		WHERE TITLE = 'с флэш на ОВМ ОД 1'

		UPDATE #sgr
		SET COEF = 0,
			COEF_OLD = 1,
			COEF_NEW = 1.25
		WHERE TITLE = 'с лок на Онлайн2'

		UPDATE #sgr
		SET COEF = ROUND(COEF, 2),
			COEF_OLD = ROUND(COEF_OLD, 2),
			COEF_NEW = ROUND(COEF_NEW, 2)

		IF @PR_ID = 300 AND @SH_ID = 1
		BEGIN
			UPDATE #sgr
			SET COEF = 0,
				COEF_OLD = 1,
				COEF_NEW = 1.5625
			WHERE TITLE = 'с лок на ОВМ ОД 1'
		END

		SELECT *
		FROM #sgr
		ORDER BY ID

		IF OBJECT_ID('tempdb..#sgr') IS NOT NULL
			DROP TABLE #sgr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_NET_COEF_GET] TO rl_subhost_calc;
GO