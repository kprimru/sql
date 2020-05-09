USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CALL_REPORT]
	@YEAR NVARCHAR(MAX) = NULL
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

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				NAME		NVARCHAR(128),
				START		SMALLDATETIME,
				YR			INT,
				CALL_CL_CNT	INT,
				SATISF_CNT	INT,
				DUTY_SATISF	INT,
				TRUST_CNT	INT
			)

		INSERT INTO #result(NAME, START, YR, CALL_CL_CNT, SATISF_CNT, DUTY_SATISF, TRUST_CNT)
			SELECT
				NAME, START, DATEPART(YEAR, START),
				(
					SELECT COUNT(*)
					FROM
						dbo.ClientCall
					WHERE CC_DATE BETWEEN START AND FINISH
				) +
				(
					SELECT COUNT(*)
					FROM dbo.ClientContact
					WHERE PERSONAL = 'Бурова'
						AND DATE BETWEEN START AND FINISH
				) AS CALL_CLIENT_COUNT,
				(
					SELECT COUNT(*)
					FROM dbo.ClientSatisfactionView WITH(NOEXPAND)
					WHERE STT_RESULT = 0
						AND CC_DATE BETWEEN START AND FINISH
				) AS SATISF_CNT,
				(
					SELECT COUNT(*)
					FROM
						dbo.ClientDutyControl
						INNER JOIN dbo.ClientCall ON CDC_ID_CALL = CC_ID
					WHERE CDC_SATISF = 1
						AND CC_DATE BETWEEN START AND FINISH
				) AS DUTY_SATISF,
				(
					SELECT COUNT(*)
					FROM dbo.ClientTrustView WITH(NOEXPAND)
					WHERE CT_TRUST = 0
						AND CC_DATE BETWEEN START AND FINISH
				) AS TRUST_CNT
			FROM Common.Period a
			WHERE TYPE = 3
				AND
				(
					@YEAR IS NULL
					AND DATEPART(YEAR, START) >= 2012
					AND START <= GETDATE()

					OR

					@YEAR IS NOT NULL
					AND DATEPART(YEAR, START) IN
						(
							SELECT DATEPART(YEAR, START)
							FROM
								dbo.TableGUIDFromXML(@YEAR) z
								INNER JOIN Common.Period y ON z.ID = y.ID
						)
				)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(NVARCHAR(64), NEWID()) + '] ON #result (YR) INCLUDE(CALL_CL_CNT, SATISF_CNT, DUTY_SATISF, TRUST_CNT)'
		EXEC (@SQL)

		SELECT
			1 AS TP, NAME, START, YR,
			0 AS CL_COUNT,
			CALL_CL_CNT, ROUND(CONVERT(FLOAT, (CALL_CL_CNT /*- NULLIF((SELECT CALL_CL_CNT FROM #result z WHERE z.START = DATEADD(QUARTER, -1, a.START)), 0)*/)) / NULLIF((SELECT CALL_CL_CNT FROM #result z WHERE z.START = DATEADD(QUARTER, -1, a.START)), 0) * 100, 2) AS CALL_CL_PRC,
			SATISF_CNT, ROUND(CONVERT(FLOAT, SATISF_CNT) / NULLIF(CALL_CL_CNT, 0) * 100, 2) AS SATISF_SERVICE, ROUND(CONVERT(FLOAT, (SATISF_CNT /*- NULLIF((SELECT SATISF_CNT FROM #result z WHERE z.START = DATEADD(QUARTER, -1, a.START)), 0)*/)) / NULLIF((SELECT SATISF_CNT FROM #result z WHERE z.START = DATEADD(QUARTER, -1, a.START)), 0) * 100, 2) AS SATISF_PRC,
			DUTY_SATISF, ROUND(CONVERT(FLOAT, DUTY_SATISF) / NULLIF(CALL_CL_CNT, 0) * 100, 2) AS DUTY_SERVICE, ROUND(CONVERT(FLOAT, (DUTY_SATISF /*- NULLIF((SELECT DUTY_SATISF FROM #result z WHERE z.START = DATEADD(QUARTER, -1, a.START)), 0)*/)) / NULLIF((SELECT DUTY_SATISF FROM #result z WHERE z.START = DATEADD(QUARTER, -1, a.START)), 0) * 100, 2) AS DUTY_PRC,
			TRUST_CNT, ROUND(CONVERT(FLOAT, TRUST_CNT) / NULLIF(CALL_CL_CNT, 0) * 100, 2) AS TRUST_SERVICE, ROUND(CONVERT(FLOAT, (TRUST_CNT /*- NULLIF((SELECT TRUST_CNT FROM #result z WHERE z.START = DATEADD(QUARTER, -1, a.START)), 0)*/)) / NULLIF((SELECT TRUST_CNT FROM #result z WHERE z.START = DATEADD(QUARTER, -1, a.START)), 0) * 100, 2) AS TRUST_PRC
		FROM #result a

		UNION ALL

		SELECT DISTINCT 2 AS TP, b.NAME, b.START, YR,
			NULL AS CL_COUNT,
			(
				SELECT AVG(CALL_CL_CNT)
				FROM #result z
				WHERE z.YR = a.YR
			), NULL,
			(
				SELECT AVG(SATISF_CNT)
				FROM #result z
				WHERE z.YR = a.YR
			), NULL, NULL,
			(
				SELECT AVG(DUTY_SATISF)
				FROM #result z
				WHERE z.YR = a.YR
			), NULL, NULL,
			(
				SELECT AVG(TRUST_CNT)
				FROM #result z
				WHERE z.YR = a.YR
			), NULL, NULL
		FROM
			#result a
			INNER JOIN Common.Period b ON a.YR = DATEPART(YEAR, b.START)
		WHERE b.TYPE = 5

		UNION ALL

		SELECT
			TP, NAME, START, YR,
			NULL AS CL_COUNT,
			CALL_CL_CNT, ROUND(CONVERT(FLOAT, (CALL_CL_CNT /*- NULLIF((SELECT SUM(CALL_CL_CNT) FROM #result z WHERE z.YR = a.YR - 1), 0)*/)) / NULLIF((SELECT SUM(CALL_CL_CNT) FROM #result z WHERE z.YR = a.YR - 1), 0) * 100, 2),
			SATISF_CNT, ROUND(CONVERT(FLOAT, SATISF_CNT) / NULLIF(CALL_CL_CNT, 0) * 100, 2), ROUND(CONVERT(FLOAT, (SATISF_CNT /*- NULLIF((SELECT SUM(SATISF_CNT) FROM #result z WHERE z.YR = a.YR - 1), 0)*/)) / NULLIF((SELECT SUM(SATISF_CNT) FROM #result z WHERE z.YR = a.YR - 1), 0) * 100, 2),
			DUTY_SATISF, ROUND(CONVERT(FLOAT, DUTY_SATISF) / NULLIF(CALL_CL_CNT, 0) * 100, 2), ROUND(CONVERT(FLOAT, (DUTY_SATISF /*- NULLIF((SELECT SUM(DUTY_SATISF) FROM #result z WHERE z.YR = a.YR - 1), 0)*/)) / NULLIF((SELECT SUM(DUTY_SATISF) FROM #result z WHERE z.YR = a.YR - 1), 0) * 100, 2),
			TRUST_CNT, ROUND(CONVERT(FLOAT, TRUST_CNT) / NULLIF(CALL_CL_CNT, 0) * 100, 2), ROUND(CONVERT(FLOAT, (TRUST_CNT /*- NULLIF((SELECT SUM(TRUST_CNT) FROM #result z WHERE z.YR = a.YR - 1), 0)*/)) / NULLIF((SELECT SUM(TRUST_CNT) FROM #result z WHERE z.YR = a.YR - 1), 0) * 100, 2)
		FROM
			(
				SELECT DISTINCT 3 AS TP, b.NAME, b.START, YR,
					(
						SELECT SUM(CALL_CL_CNT)
						FROM #result z
						WHERE z.YR = a.YR
					) AS CALL_CL_CNT,
					(
						SELECT SUM(SATISF_CNT)
						FROM #result z
						WHERE z.YR = a.YR
					) AS SATISF_CNT,
					(
						SELECT SUM(DUTY_SATISF)
						FROM #result z
						WHERE z.YR = a.YR
					) AS DUTY_SATISF,
					(
						SELECT SUM(TRUST_CNT)
						FROM #result z
						WHERE z.YR = a.YR
					) AS TRUST_CNT
				FROM
					#result a
					INNER JOIN Common.Period b ON a.YR = DATEPART(YEAR, b.START)
				WHERE b.TYPE = 5
			) AS a

		ORDER BY YR, TP, START

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CALL_REPORT] TO rl_blank_report;
GO