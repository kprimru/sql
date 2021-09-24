USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Memo].[KGS_MEMO_PRINT]
	@ID		UNIQUEIDENTIFIER,
	/*
	Режим печати:
	1. Offer	-	Коммерческое предложение
	2. Letter	-	Информационное письмо
	3. Memo		-	Служебная записка
	*/
	@MODE	TINYINT,
	@CURVED	TINYINT = 1
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

		IF @MODE = 1
		BEGIN
			SELECT 
				ROW_NUMBER() OVER(PARTITION BY d.ID_CLIENT ORDER BY NUM, f.SystemOrder, DistrTypeOrder, DISTR) AS RN,
				a.NAME, DATE, CONVERT(VARCHAR(20), DATE, 104) AS DATE_S,
				b.NAME AS MON_NAME,
				CONVERT(VARCHAR(20), CASE @CURVED WHEN 1 THEN b.START ELSE c.START END, 104) AS PERIOD_BEGIN,
				CONVERT(VARCHAR(20), c.FINISH, 104) AS PERIOD_END,
				d.NAME AS CLIENT, d.ADDRESS, d.NUM,
				CASE ISNULL(h.SystemPrefix, '')
					WHEN '' THEN ''
					ELSE h.SystemPrefix + ' '
				END + h.SystemName + ''
				/*CASE ISNULL(h.SystemPostfix, '')
					WHEN '' THEN ''
					ELSE ' ' + h.SystemPostfix
				END*/ AS SYS_NAME,
				DistrTypeName AS NET,
				dbo.DistrString(NULL, DISTR, COMP) AS DISTR,
				TOTAL_PRICE, TOTAL_PERIOD,
				(
					SELECT COUNT(*)
					FROM Memo.KGSMemoDistr z
					WHERE z.ID_MEMO = d.ID_MEMO AND z.ID_CLIENT = d.ID_CLIENT AND CURVED = @CURVED
				) AS DIS_COUNT
			FROM
				Memo.KGSMemo a
				INNER JOIN Memo.KGSMemoClient d ON d.ID_MEMO = a.ID
				INNER JOIN Memo.KGSMemoDistr e ON e.ID_MEMO = d.ID_MEMO AND e.ID_CLIENT = d.ID_CLIENT
				INNER JOIN Common.Period b ON a.ID_MONTH = b.ID
				INNER JOIN Common.Period c ON DATEADD(MONTH, e.MON_CNT - 1, b.START) = c.START AND b.TYPE = c.TYPE
				INNER JOIN dbo.SystemTable f ON f.SystemID = e.ID_SYSTEM
				INNER JOIN dbo.DistrTypeTable g ON g.DistrTypeID = e.ID_NET
				LEFT OUTER JOIN dbo.SystemBuhView h ON h.SystemReg = f.SystemBaseName
			WHERE a.ID = @ID AND CURVED = @CURVED
			ORDER BY NUM, RN
		END
		ELSE IF @MODE = 2
		BEGIN
			SELECT 
				ROW_NUMBER() OVER(ORDER BY e.SystemOrder, DistrTypeOrder) AS NUM,
				a.NAME, DATE, CONVERT(VARCHAR(20), DATE, 104) AS DATE_S,
				b.NAME AS MON_NAME,
				CONVERT(VARCHAR(20), CASE @CURVED WHEN 1 THEN b.START ELSE c.START END, 104) AS PERIOD_BEGIN,
				CONVERT(VARCHAR(20), c.FINISH, 104) AS PERIOD_END,
				/*d.NAME AS CLIENT, d.ADDRESS, d.NUM,*/
				CASE ISNULL(g.SystemPrefix, '')
					WHEN '' THEN ''
					ELSE g.SystemPrefix + ' '
				END + g.SystemName + ''
				/*CASE ISNULL(g.SystemPostfix, '')
					WHEN '' THEN ''
					ELSE ' ' + g.SystemPostfix
				END*/ AS SYS_NAME,
				DistrTypeName AS NET,
				(
					SELECT COUNT(*)
					FROM Memo.KGSMemoDistr z
					WHERE z.ID_MEMO = a.ID
						AND z.ID_SYSTEM = d.ID_SYSTEM
						AND z.ID_NET = d.ID_NET
						--AND z.CURVED = @CURVED
				) AS CNT,
				(
					SELECT TOP 1 TOTAL_PRICE
					FROM Memo.KGSMemoDistr z
					WHERE z.ID_MEMO = a.ID
						AND z.ID_SYSTEM = d.ID_SYSTEM
						AND z.ID_NET = d.ID_NET
						AND z.CURVED = @CURVED
					ORDER BY TOTAL_PRICE
				) AS PRICE,
				(
					SELECT SUM(TOTAL_PRICE)
					FROM Memo.KGSMemoDistr z
					WHERE z.ID_MEMO = a.ID
						AND z.ID_SYSTEM = d.ID_SYSTEM
						AND z.ID_NET = d.ID_NET
						AND z.CURVED = @CURVED
				) AS SUMM,
				(
					SELECT SUM(TOTAL_PRICE)
					FROM Memo.KGSMemoDistr z
					WHERE z.ID_MEMO = a.ID
						AND z.ID_SYSTEM = d.ID_SYSTEM
						AND z.ID_NET = d.ID_NET
						AND z.CURVED = @CURVED
				) * CASE @CURVED WHEN 1 THEN d.MON_CNT ELSE 1 END AS TOTAL_PERIOD
			FROM
				Memo.KGSMemo a
				INNER JOIN
					(
						SELECT DISTINCT ID_MEMO, ID_SYSTEM, ID_NET, MON_CNT
						FROM Memo.KGSMemoDistr
						WHERE CURVED = @CURVED
							AND ID_MEMO = @ID
					) AS d ON d.ID_MEMO = a.ID
				INNER JOIN Common.Period b ON a.ID_MONTH = b.ID
				INNER JOIN Common.Period c ON DATEADD(MONTH, d.MON_CNT - 1, b.START) = c.START AND b.TYPE = c.TYPE
				INNER JOIN dbo.SystemTable e ON e.SystemID = d.ID_SYSTEM
				INNER JOIN dbo.DistrTypeTable f ON f.DistrTypeID = d.ID_NET
				LEFT OUTER JOIN dbo.SystemBuhView g ON g.SystemReg = e.SystemBaseName
			WHERE a.ID = @ID
			ORDER BY e.SystemOrder, DistrTypeOrder
		END
		ELSE IF @MODE = 3
		BEGIN
			IF OBJECT_ID('tempdb..#result') IS NOT NULL
				DROP TABLE #result

			CREATE TABLE #result
				(
					RN				INT,
					NAME			NVARCHAR(128),
					DATE			SMALLDATETIME,
					DATE_S			VARCHAR(20),
					MON_NAME		VARCHAR(32),
					PERIOD_BEGIN	VARCHAR(32),
					PERIOD_END		VARCHAR(32),
					CLIENT			VARCHAR(500),
					ADDRESS			VARCHAR(500),
					NUM				INT,
					SYS_NAME		VARCHAR(1000),
					SYS_ORDER		INT,
					NET				VARCHAR(50),
					NET_ORDER		INT,
					DISTR			VARCHAR(50),
					PRICE			MONEY,
					TAX_PRICE		MONEY,
					TOTAL_PRICE		MONEY,
					DIS_COUNT		INT
				)

			INSERT INTO #result(
					RN, NAME, DATE, DATE_S, MON_NAME, PERIOD_BEGIN, PERIOD_END,
					CLIENT, ADDRESS, NUM, SYS_NAME, SYS_ORDER, NET, NET_ORDER,
					DISTR, PRICE, TAX_PRICE, TOTAL_PRICE, DIS_COUNT
					)
				SELECT 
					ROW_NUMBER() OVER(PARTITION BY d.ID_CLIENT ORDER BY NUM, f.SystemOrder, DistrTypeOrder, DISTR) AS RN,
					a.NAME, DATE, CONVERT(VARCHAR(20), DATE, 104) AS DATE_S,
					b.NAME AS MON_NAME,
					CONVERT(VARCHAR(20), CASE @CURVED WHEN 1 THEN b.START ELSE c.START END, 104) AS PERIOD_BEGIN,
					CONVERT(VARCHAR(20), c.FINISH, 104) AS PERIOD_END,
					d.NAME AS CLIENT, d.ADDRESS, d.NUM,
					CASE ISNULL(h.SystemPrefix, '')
						WHEN '' THEN ''
						ELSE h.SystemPrefix + ' '
					END + h.SystemName + ''
					/*CASE ISNULL(h.SystemPostfix, '')
						WHEN '' THEN ''
						ELSE ' ' + h.SystemPostfix
					END*/ AS SYS_NAME, f.SystemOrder,
					DistrTypeName AS NET, DistrTypeOrder,
					dbo.DistrString(NULL, DISTR, COMP) AS DISTR,
					e.PRICE, TAX_PRICE, TOTAL_PRICE,
					(
						SELECT COUNT(*)
						FROM Memo.KGSMemoDistr z
						WHERE z.ID_MEMO = d.ID_MEMO AND z.ID_CLIENT = d.ID_CLIENT AND z.CURVED = @CURVED
					) AS DIS_COUNT
				FROM
					Memo.KGSMemo a
					INNER JOIN Memo.KGSMemoClient d ON d.ID_MEMO = a.ID
					INNER JOIN Memo.KGSMemoDistr e ON e.ID_MEMO = d.ID_MEMO AND e.ID_CLIENT = d.ID_CLIENT
					INNER JOIN Common.Period b ON a.ID_MONTH = b.ID
					INNER JOIN Common.Period c ON DATEADD(MONTH, e.MON_CNT - 1, b.START) = c.START AND b.TYPE = c.TYPE
					INNER JOIN dbo.SystemTable f ON f.SystemID = e.ID_SYSTEM
					INNER JOIN dbo.DistrTypeTable g ON g.DistrTypeID = e.ID_NET
					LEFT OUTER JOIN dbo.SystemBuhView h ON h.SystemReg = f.SystemBaseName
				WHERE a.ID = @ID AND e.CURVED = @CURVED

			SELECT
				0 AS TOTAL,
				1 AS TP,
				RN, NAME, DATE, DATE_S, MON_NAME, PERIOD_BEGIN, PERIOD_END,
				CLIENT, ADDRESS, NUM, SYS_NAME, SYS_ORDER, NET, NET_ORDER,
				DISTR, PRICE, TAX_PRICE, TOTAL_PRICE, DIS_COUNT
			FROM #result

			UNION ALL

			SELECT
				0 AS TOTAL,
				2 AS TP,
				NULL, NAME, DATE, DATE_S, MON_NAME, PERIOD_BEGIN, PERIOD_END,
				NULL, NULL, NUM, NULL, NULL, NULL, NULL,
				NULL, SUM(PRICE), SUM(TAX_PRICE), SUM(TOTAL_PRICE), NULL
			FROM #result
			GROUP BY NAME, DATE, DATE_S, MON_NAME, PERIOD_BEGIN, PERIOD_END, NUM

			UNION ALL

			SELECT
				1 AS TOTAL,
				3 AS TP,
				NULL, NAME, DATE, DATE_S, MON_NAME, PERIOD_BEGIN, PERIOD_END,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, SUM(PRICE), SUM(TAX_PRICE), SUM(TOTAL_PRICE), NULL
			FROM #result
			GROUP BY NAME, DATE, DATE_S, MON_NAME, PERIOD_BEGIN, PERIOD_END

			ORDER BY TOTAL, NUM, TP, SYS_ORDER, NET_ORDER, DISTR

			IF OBJECT_ID('tempdb..#result') IS NOT NULL
				DROP TABLE #result
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
GRANT EXECUTE ON [Memo].[KGS_MEMO_PRINT] TO rl_kgs_complect_calc;
GO
