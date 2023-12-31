USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STAT_BY_MONTH]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@SERVER	INT
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

	    IF OBJECT_ID('tempdb..#month_stat') IS NOT NULL
		    DROP TABLE #month_stat

	    CREATE TABLE #month_stat
		    (
			    ID					INT IDENTITY(1, 1) PRIMARY KEY,
			    DT					SMALLDATETIME,
			    TP					TINYINT, /* 1 - ���, 2 - �����, 3 - ���� */
			    QST_SIZE			BIGINT,
			    QST_PERCENT			DECIMAL(18, 4),
			    ANS_SIZE			BIGINT,
			    ANS_PERCENT			DECIMAL(18, 4),
			    CACHE_SIZE			BIGINT,
			    CACHE_PERCENT		DECIMAL(18, 4),
			    REPORT_SIZE			BIGINT,
			    REPORT_PERCENT		DECIMAL(18, 4),
			    TRAFIN				BIGINT,
			    TRAFIN_PERCENT		DECIMAL(18, 4),
			    TRAFOUT				BIGINT,
			    TRAFOUT_PERCENT		DECIMAL(18, 4),
			    US_COUNT			INT,
			    US_COUNT_PERCENT	DECIMAL(18, 4)
		    )

	    INSERT INTO #month_stat(DT, TP, QST_SIZE, ANS_SIZE, CACHE_SIZE, REPORT_SIZE, TRAFIN, TRAFOUT, US_COUNT)
		    SELECT
			    CONVERT(SMALLDATETIME, CONVERT(VARCHAR(4), YR) + '0101', 112), 1, QST_SIZE, ANS_SIZE, CACHE_SIZE, REPORT_SIZE, TRAFIN, TRAFOUT,
			    (
				    SELECT COUNT(*)
				    FROM
					    (
						    SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
						    FROM dbo.ClientStatDistrView z WITH(NOEXPAND)
						    WHERE DATEPART(YEAR, z.CSD_MONTH) = o_O.YR
							    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
					    ) AS pp
			    ) AS US_COUNT
		    FROM
			    (
				    SELECT
					    DATEPART(YEAR, CSD_MONTH) AS YR,
					    SUM(CSD_QST_SIZE) AS QST_SIZE,
					    SUM(CSD_ANS_SIZE) AS ANS_SIZE,
					    SUM(CSD_CACHE_SIZE) AS CACHE_SIZE,
					    SUM(CSD_REPORT_SIZE) AS REPORT_SIZE
				    FROM dbo.ClientStatView WITH(NOEXPAND)
				    WHERE (CSD_DAY >= @BEGIN OR @BEGIN IS NULL)
					    AND (CSD_DAY <= @END OR @END IS NULL)
					    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
				    GROUP BY DATEPART(YEAR, CSD_MONTH)
			    ) AS o_O INNER JOIN
			    (
				    SELECT
					    DATEPART(YEAR, SSD_MONTH) AS YRS,
					    SUM(SSD_TRAFIN) AS TRAFIN,
					    SUM(SSD_TRAFOUT) AS TRAFOUT
				    FROM dbo.ServerStatView WITH(NOEXPAND)
				    WHERE (SSD_DAY >= @BEGIN OR @BEGIN IS NULL)
					    AND (SSD_DAY <= @END OR @END IS NULL)
					    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
				    GROUP BY DATEPART(YEAR, SSD_MONTH)
			    ) AS o ON YR = YRS

	    INSERT INTO #month_stat(DT, TP, QST_SIZE, ANS_SIZE, CACHE_SIZE, REPORT_SIZE, TRAFIN, TRAFOUT, US_COUNT)
		    SELECT
			    DT, 2, QST_SIZE, ANS_SIZE, CACHE_SIZE, REPORT_SIZE, TRAFIN, TRAFOUT,
			    (
				    SELECT COUNT(*)
				    FROM
					    (
						    SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
						    FROM dbo.ClientStatDistrView z WITH(NOEXPAND)
						    WHERE z.CSD_MONTH = o_O.DT
							    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
					    ) AS pp
			    ) AS US_COUNT
		    FROM
			    (
				    SELECT
					    CSD_MONTH AS DT,
					    SUM(CSD_QST_SIZE) AS QST_SIZE,
					    SUM(CSD_ANS_SIZE) AS ANS_SIZE,
					    SUM(CSD_CACHE_SIZE) AS CACHE_SIZE,
					    SUM(CSD_REPORT_SIZE) AS REPORT_SIZE
				    FROM dbo.ClientStatView WITH(NOEXPAND)
				    WHERE (CSD_DAY >= @BEGIN OR @BEGIN IS NULL)
					    AND (CSD_DAY <= @END OR @END IS NULL)
					    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
				    GROUP BY CSD_MONTH
			    ) AS o_O INNER JOIN
			    (
				    SELECT
					    SSD_MONTH AS DTS,
					    SUM(SSD_TRAFIN) AS TRAFIN,
					    SUM(SSD_TRAFOUT) AS TRAFOUT
				    FROM dbo.ServerStatView WITH(NOEXPAND)
				    WHERE (SSD_DAY >= @BEGIN OR @BEGIN IS NULL)
					    AND (SSD_DAY <= @END OR @END IS NULL)
					    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
				    GROUP BY SSD_MONTH
			    ) AS o ON DT = DTS

	    UPDATE a
	    SET
		    QST_PERCENT			= 100 * CONVERT(DECIMAL(28, 4), (a.QST_SIZE - b.QST_SIZE)) / b.QST_SIZE,
		    ANS_PERCENT			= 100 * CONVERT(DECIMAL(28, 4), (a.ANS_SIZE - b.ANS_SIZE)) / b.ANS_SIZE,
		    CACHE_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.CACHE_SIZE - b.CACHE_SIZE)) / b.CACHE_SIZE,
		    REPORT_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.REPORT_SIZE - b.REPORT_SIZE)) / b.REPORT_SIZE,
		    TRAFIN_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.TRAFIN - b.TRAFIN)) / b.TRAFIN,
		    TRAFOUT_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.TRAFOUT - b.TRAFOUT)) / b.TRAFOUT,
		    US_COUNT_PERCENT	= 100 * CONVERT(DECIMAL(28, 4), (a.US_COUNT - b.US_COUNT)) / b.US_COUNT
	    FROM
		    #month_stat a
		    INNER JOIN #month_stat b ON a.DT = DATEADD(YEAR, 1, b.DT)
	    WHERE a.TP = 1 AND b.TP = 1
    
	    UPDATE a
	    SET
		    QST_PERCENT			= 100 * CONVERT(DECIMAL(28, 4), (a.QST_SIZE - b.QST_SIZE)) / b.QST_SIZE,
		    ANS_PERCENT			= 100 * CONVERT(DECIMAL(28, 4), (a.ANS_SIZE - b.ANS_SIZE)) / b.ANS_SIZE,
		    CACHE_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.CACHE_SIZE - b.CACHE_SIZE)) / b.CACHE_SIZE,
		    REPORT_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.REPORT_SIZE - b.REPORT_SIZE)) / b.REPORT_SIZE,
		    TRAFIN_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.TRAFIN - b.TRAFIN)) / b.TRAFIN,
		    TRAFOUT_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.TRAFOUT - b.TRAFOUT)) / b.TRAFOUT,
		    US_COUNT_PERCENT	= 100 * CONVERT(DECIMAL(28, 4), (a.US_COUNT - b.US_COUNT)) / b.US_COUNT
	    FROM
		    #month_stat a
		    INNER JOIN #month_stat b ON a.DT = DATEADD(MONTH, 1, b.DT)
	    WHERE a.TP = 2 AND b.TP = 2

	    INSERT INTO #month_stat(DT, TP, QST_SIZE, ANS_SIZE, CACHE_SIZE, REPORT_SIZE, TRAFIN, TRAFOUT, US_COUNT)
		    SELECT 
			    CSD_DAY, 3,
			    QST_SIZE,
			    ANS_SIZE,
			    CACHE_SIZE,
			    REPORT_SIZE,
			    TRAFIN,
			    TRAFOUT,
			    (
				    SELECT COUNT(*)
				    FROM
					    (
						    SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
						    FROM dbo.ClientStatDistrView z WITH(NOEXPAND)
						    WHERE z.CSD_DAY = o_O.CSD_DAY
							    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
					    ) AS pp
			    ) AS US_COUNT
		    FROM
			    (
				    SELECT
					    CSD_MONTH AS DT,
					    CSD_DAY,
					    SUM(CSD_QST_SIZE) AS QST_SIZE,
					    SUM(CSD_ANS_SIZE) AS ANS_SIZE,
					    SUM(CSD_CACHE_SIZE) AS CACHE_SIZE,
					    SUM(CSD_REPORT_SIZE) AS REPORT_SIZE
				    FROM dbo.ClientStatView WITH(NOEXPAND)
				    WHERE (CSD_DAY >= @BEGIN OR @BEGIN IS NULL)
					    AND (CSD_DAY <= @END OR @END IS NULL)
					    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
				    GROUP BY CSD_MONTH, CSD_DAY
			    ) AS o_O INNER JOIN
			    (
				    SELECT
					    SSD_MONTH AS DTS,
					    SSD_DAY,
					    SUM(SSD_TRAFIN) AS TRAFIN,
					    SUM(SSD_TRAFOUT) AS TRAFOUT
				    FROM dbo.ServerStatView WITH(NOEXPAND)
				    WHERE (SSD_DAY >= @BEGIN OR @BEGIN IS NULL)
					    AND (SSD_DAY <= @END OR @END IS NULL)
					    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
				    GROUP BY SSD_MONTH, SSD_DAY
			    ) AS o ON CSD_DAY = SSD_DAY
    
	    SELECT
		    ID, NULL AS ID_MASTER,
		    DT AS REP_DAY,
		    DT AS REP_MONTH,
		    CONVERT(VARCHAR(20), DATEPART(YEAR, DT)) AS MONTH_NAME,
		    dbo.FileSizeToStr(QST_SIZE) AS QST_SIZE,
		    QST_PERCENT,
		    dbo.FileSizeToStr(ANS_SIZE) AS ANS_SIZE,
		    ANS_PERCENT,
		    dbo.FileSizeToStr(CACHE_SIZE) AS CACHE_SIZE,
		    CACHE_PERCENT,
		    dbo.FileSizeToStr(REPORT_SIZE) AS REPORT_SIZE,
		    REPORT_PERCENT,
		    dbo.FileSizeToStr(QST_SIZE + REPORT_SIZE) AS IN_SIZE,
		    dbo.FileSizeToStr(ANS_SIZE + CACHE_SIZE) AS OUT_SIZE,
		    dbo.FileSizeToStr(TRAFIN) AS TRAFIN,
		    TRAFIN_PERCENT,
		    dbo.FileSizeToStr(TRAFOUT) AS TRAFOUT,
		    TRAFOUT_PERCENT,
		    US_COUNT,
		    US_COUNT_PERCENT
	    FROM #month_stat
	    WHERE TP = 1
    
	    UNION ALL
    
	    SELECT
		    ID,
		    (
			    SELECT ID
			    FROM #month_stat b
			    WHERE TP = 1 AND DATEPART(YEAR, a.DT) = DATEPART(YEAR, b.DT)
		    ) AS ID_MASTER,
		    DT AS REP_DAY,
		    DT AS REP_MONTH,
		    DATENAME(MONTH, DT) + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, DT)) AS MONTH_NAME,
		    dbo.FileSizeToStr(QST_SIZE) AS QST_SIZE,
		    QST_PERCENT,
		    dbo.FileSizeToStr(ANS_SIZE) AS ANS_SIZE,
		    ANS_PERCENT,
		    dbo.FileSizeToStr(CACHE_SIZE) AS CACHE_SIZE,
		    CACHE_PERCENT,
		    dbo.FileSizeToStr(REPORT_SIZE) AS REPORT_SIZE,
		    REPORT_PERCENT,
		    dbo.FileSizeToStr(QST_SIZE + REPORT_SIZE) AS IN_SIZE,
		    dbo.FileSizeToStr(ANS_SIZE + CACHE_SIZE) AS OUT_SIZE,
		    dbo.FileSizeToStr(TRAFIN) AS TRAFIN,
		    TRAFIN_PERCENT,
		    dbo.FileSizeToStr(TRAFOUT) AS TRAFOUT,
		    TRAFOUT_PERCENT,
		    US_COUNT,
		    US_COUNT_PERCENT
	    FROM #month_stat a
	    WHERE TP = 2
    
	    UNION ALL
    
	    SELECT
		    ID,
		    (
			    SELECT ID
			    FROM #month_stat b
			    WHERE TP = 2
				    AND DATEPART(YEAR, a.DT) = DATEPART(YEAR, b.DT)
				    AND DATEPART(MONTH, a.DT) = DATEPART(MONTH, b.DT)
		    ) AS ID_MASTER,
		    DT AS REP_DAY,
		    DT AS REP_MONTH,
		    DATENAME(DAY, DT) + ' ' + DATENAME(MONTH, DT) + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, DT)) AS MONTH_NAME,
		    dbo.FileSizeToStr(QST_SIZE) AS QST_SIZE,
		    QST_PERCENT,
		    dbo.FileSizeToStr(ANS_SIZE) AS ANS_SIZE,
		    ANS_PERCENT,
		    dbo.FileSizeToStr(CACHE_SIZE) AS CACHE_SIZE,
		    CACHE_PERCENT,
		    dbo.FileSizeToStr(REPORT_SIZE) AS REPORT_SIZE,
		    REPORT_PERCENT,
		    dbo.FileSizeToStr(QST_SIZE + REPORT_SIZE) AS IN_SIZE,
		    dbo.FileSizeToStr(ANS_SIZE + CACHE_SIZE) AS OUT_SIZE,
		    dbo.FileSizeToStr(TRAFIN) AS TRAFIN,
		    TRAFIN_PERCENT,
		    dbo.FileSizeToStr(TRAFOUT) AS TRAFOUT,
		    TRAFOUT_PERCENT,
		    US_COUNT,
		    US_COUNT_PERCENT
	    FROM #month_stat a
	    WHERE TP = 3
    
	    ORDER BY REP_MONTH DESC, REP_DAY DESC

	    /*
	    SELECT
		    DATENAME(MONTH, DATEADD(MONTH, CONVERT(INT, RIGHT(DT, 2)) - 1, '20110101')) + ' ' + LEFT(DT, 4) AS MONTH_NAME,
		    dbo.FileSizeToStr(QST_SIZE) AS QST_SIZE,
		    dbo.FileSizeToStr(ANS_SIZE) AS ANS_SIZE,
		    dbo.FileSizeToStr(CACHE_SIZE) AS CACHE_SIZE,
		    dbo.FileSizeToStr(REPORT_SIZE) AS REPORT_SIZE,
		    dbo.FileSizeToStr(QST_SIZE + REPORT_SIZE) AS IN_SIZE,
		    dbo.FileSizeToStr(ANS_SIZE + CACHE_SIZE) AS OUT_SIZE,
		    dbo.FileSizeToStr(TRAFIN) AS TRAFIN,
		    dbo.FileSizeToStr(TRAFOUT) AS TRAFOUT,
		    (
			    SELECT COUNT(*)
			    FROM
				    (
					    SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
					    FROM
						    dbo.ClientStat INNER JOIN
						    dbo.Files ON FL_ID = CS_ID_FILE INNER JOIN
						    dbo.ClientStatDetail ON CSD_ID_CS = CS_ID
					    WHERE SUBSTRING(RIGHT(FL_NAME, 22), 12, 7) = o_O.DT
				    ) AS pp
		    ) AS US_COUNT
	    FROM
		    (
			    SELECT
				    SUBSTRING(RIGHT(FL_NAME, 22), 12, 7) AS DT,
				    SUM(CSD_QST_SIZE) AS QST_SIZE,
				    SUM(CSD_ANS_SIZE) AS ANS_SIZE,
				    SUM(CSD_CACHE_SIZE) AS CACHE_SIZE,
				    SUM(CSD_REPORT_SIZE) AS REPORT_SIZE
			    FROM
				    dbo.ClientStat INNER JOIN
				    dbo.Files ON FL_ID = CS_ID_FILE INNER JOIN
				    dbo.ClientStatDetail ON CSD_ID_CS = CS_ID
			    GROUP BY FL_NAME
		    ) AS o_O INNER JOIN
		    (
			    SELECT
				    SUBSTRING(RIGHT(FL_NAME, 22), 12, 7) AS DTS,
				    SUM(SSD_TRAFIN) AS TRAFIN,
				    SUM(SSD_TRAFOUT) AS TRAFOUT
			    FROM
				    dbo.ServerStat INNER JOIN
				    dbo.Files ON FL_ID = SS_ID_FILE INNER JOIN
				    dbo.ServerStatDetail ON SSD_ID_SD = SS_ID
			    GROUP BY FL_NAME
		    ) AS o ON DT = DTS
	    ORDER BY DT DESC
	    */
    
    
	    /*
	    IF OBJECT_ID('tempdb..#month_stat') IS NOT NULL
		    DROP TABLE #month_stat

	    CREATE TABLE #month_stat
		    (
			    DT			SMALLDATETIME PRIMARY KEY,
			    QST_SIZE	BIGINT,
			    QST_PERCENT	DECIMAL(18, 4),
			    ANS_SIZE	BIGINT,
			    ANS_PERCENT	DECIMAL(18, 4),
			    CACHE_SIZE	BIGINT,
			    CACHE_PERCENT	DECIMAL(18, 4),
			    REPORT_SIZE	BIGINT,
			    REPORT_PERCENT	DECIMAL(18, 4),
			    TRAFIN		BIGINT,
			    TRAFIN_PERCENT	DECIMAL(18, 4),
			    TRAFOUT		BIGINT,
			    TRAFOUT_PERCENT	DECIMAL(18, 4),
			    US_COUNT	INT,
			    US_COUNT_PERCENT	DECIMAL(18, 4)
		    )

	    INSERT INTO #month_stat(DT, QST_SIZE, ANS_SIZE, CACHE_SIZE, REPORT_SIZE, TRAFIN, TRAFOUT, US_COUNT)
		    SELECT
			    DT, QST_SIZE, ANS_SIZE, CACHE_SIZE, REPORT_SIZE, TRAFIN, TRAFOUT,
			    (
				    SELECT COUNT(*)
				    FROM
					    (
						    SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
						    FROM dbo.ClientStatDistrView z WITH(NOEXPAND)
							    /*
							    dbo.ClientStatDetail z
							    INNER JOIN dbo.ClientStat y ON y.CS_ID = z.CSD_ID_CS
							    INNER JOIN dbo.Files x ON FL_ID = CS_ID_FILE
							    */
						    WHERE z.CSD_MONTH = o_O.DT
							    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
					    ) AS pp
			    ) AS US_COUNT
		    FROM
			    (
				    SELECT
					    CSD_MONTH AS DT,
					    SUM(CSD_QST_SIZE) AS QST_SIZE,
					    SUM(CSD_ANS_SIZE) AS ANS_SIZE,
					    SUM(CSD_CACHE_SIZE) AS CACHE_SIZE,
					    SUM(CSD_REPORT_SIZE) AS REPORT_SIZE
				    FROM dbo.ClientStatView WITH(NOEXPAND)
				    WHERE (CSD_DAY >= @BEGIN OR @BEGIN IS NULL)
					    AND (CSD_DAY <= @END OR @END IS NULL)
					    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
				    GROUP BY CSD_MONTH
			    ) AS o_O INNER JOIN
			    (
				    SELECT
					    SSD_MONTH AS DTS,
					    SUM(SSD_TRAFIN) AS TRAFIN,
					    SUM(SSD_TRAFOUT) AS TRAFOUT
				    FROM dbo.ServerStatView WITH(NOEXPAND)
				    WHERE (SSD_DAY >= @BEGIN OR @BEGIN IS NULL)
					    AND (SSD_DAY <= @END OR @END IS NULL)
					    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
				    GROUP BY SSD_MONTH
			    ) AS o ON DT = DTS

	    UPDATE a
	    SET
		    QST_PERCENT			= 100 * CONVERT(DECIMAL(28, 4), (a.QST_SIZE - b.QST_SIZE)) / b.QST_SIZE,
		    ANS_PERCENT			= 100 * CONVERT(DECIMAL(28, 4), (a.ANS_SIZE - b.ANS_SIZE)) / b.ANS_SIZE,
		    CACHE_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.CACHE_SIZE - b.CACHE_SIZE)) / b.CACHE_SIZE,
		    REPORT_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.REPORT_SIZE - b.REPORT_SIZE)) / b.REPORT_SIZE,
		    TRAFIN_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.TRAFIN - b.TRAFIN)) / b.TRAFIN,
		    TRAFOUT_PERCENT		= 100 * CONVERT(DECIMAL(28, 4), (a.TRAFOUT - b.TRAFOUT)) / b.TRAFOUT,
		    US_COUNT_PERCENT	= 100 * CONVERT(DECIMAL(28, 4), (a.US_COUNT - b.US_COUNT)) / b.US_COUNT
	    FROM
		    #month_stat a
		    INNER JOIN #month_stat b ON a.DT = DATEADD(MONTH, 1, b.DT)

	    SELECT
		    0 + 100 * DATEPART(MONTH, DT) + 10000 * DATEPART(YEAR, DT) AS ID,
		    NULL AS ID_MASTER,
		    DT AS REP_DAY,
		    DT AS REP_MONTH,
		    DATENAME(MONTH, DT) + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, DT)) AS MONTH_NAME,
		    dbo.FileSizeToStr(QST_SIZE) AS QST_SIZE,
		    QST_PERCENT,
		    dbo.FileSizeToStr(ANS_SIZE) AS ANS_SIZE,
		    ANS_PERCENT,
		    dbo.FileSizeToStr(CACHE_SIZE) AS CACHE_SIZE,
		    CACHE_PERCENT,
		    dbo.FileSizeToStr(REPORT_SIZE) AS REPORT_SIZE,
		    REPORT_PERCENT,
		    dbo.FileSizeToStr(QST_SIZE + REPORT_SIZE) AS IN_SIZE,
		    dbo.FileSizeToStr(ANS_SIZE + CACHE_SIZE) AS OUT_SIZE,
		    dbo.FileSizeToStr(TRAFIN) AS TRAFIN,
		    TRAFIN_PERCENT,
		    dbo.FileSizeToStr(TRAFOUT) AS TRAFOUT,
		    TRAFOUT_PERCENT,
		    US_COUNT,
		    US_COUNT_PERCENT
	    FROM #month_stat
    
	    UNION ALL

	    SELECT
		    DATEPART(DAY, CSD_DAY) + 100 * DATEPART(MONTH, CSD_DAY) + 10000 * DATEPART(YEAR, CSD_DAY) AS ID,
		    0 + 100 * DATEPART(MONTH, CSD_DAY) + 10000 * DATEPART(YEAR, CSD_DAY) AS ID_MASTER,
		    CSD_DAY AS REP_DAY,
		    DT AS REP_MONTH,
		    CONVERT(VARCHAR(20), DATEPART(DAY, CSD_DAY)) + ' ' +
			    DATENAME(MONTH, CSD_DAY) + ' (' +
			    DATENAME(WEEKDAY, CSD_DAY) + ')' AS MONTH_NAME,
		    dbo.FileSizeToStr(QST_SIZE) AS QST_SIZE,
		    NULL,
		    dbo.FileSizeToStr(ANS_SIZE) AS ANS_SIZE,
		    NULL,
		    dbo.FileSizeToStr(CACHE_SIZE) AS CACHE_SIZE,
		    NULL,
		    dbo.FileSizeToStr(REPORT_SIZE) AS REPORT_SIZE,
		    NULL,
		    dbo.FileSizeToStr(QST_SIZE + REPORT_SIZE) AS IN_SIZE,
		    dbo.FileSizeToStr(ANS_SIZE + CACHE_SIZE) AS OUT_SIZE,
		    dbo.FileSizeToStr(TRAFIN) AS TRAFIN,
		    NULL,
		    dbo.FileSizeToStr(TRAFOUT) AS TRAFOUT,
		    NULL,
		    (
			    SELECT COUNT(*)
			    FROM
				    (
					    SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
					    FROM dbo.ClientStatDistrView z WITH(NOEXPAND)
						    /*
						    dbo.ClientStatDetail z
						    INNER JOIN dbo.ClientStat y ON y.CS_ID = z.CSD_ID_CS
						    INNER JOIN dbo.Files x ON FL_ID = CS_ID_FILE
						    */
					    WHERE z.CSD_DAY = o_O.CSD_DAY
						    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
				    ) AS pp
		    ) AS US_COUNT,
		    NULL
	    FROM
		    (
			    SELECT
				    CSD_MONTH AS DT,
				    CSD_DAY,
				    SUM(CSD_QST_SIZE) AS QST_SIZE,
				    SUM(CSD_ANS_SIZE) AS ANS_SIZE,
				    SUM(CSD_CACHE_SIZE) AS CACHE_SIZE,
				    SUM(CSD_REPORT_SIZE) AS REPORT_SIZE
			    FROM dbo.ClientStatView WITH(NOEXPAND)
				    /*
				    dbo.ClientStatDetail
				    INNER JOIN dbo.ClientStat ON CS_ID = CSD_ID_CS
				    INNER JOIN dbo.Files ON FL_ID = CS_ID_FILE
				    */
			    WHERE (CSD_DAY >= @BEGIN OR @BEGIN IS NULL)
				    AND (CSD_DAY <= @END OR @END IS NULL)
				    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
			    GROUP BY CSD_MONTH, CSD_DAY
		    ) AS o_O INNER JOIN
		    (
			    SELECT
				    SSD_MONTH AS DTS,
				    SSD_DAY,
				    SUM(SSD_TRAFIN) AS TRAFIN,
				    SUM(SSD_TRAFOUT) AS TRAFOUT
			    FROM dbo.ServerStatView WITH(NOEXPAND)
				    /*
				    dbo.ServerStatDetail
				    INNER JOIN dbo.ServerStat ON SS_ID = SSD_ID_SD
				    INNER JOIN dbo.Files ON FL_ID = SS_ID_FILE
				    */
			    WHERE (SSD_DAY >= @BEGIN OR @BEGIN IS NULL)
				    AND (SSD_DAY <= @END OR @END IS NULL)
				    AND (FL_ID_SERVER = @SERVER OR @SERVER IS NULL)
			    GROUP BY SSD_MONTH, SSD_DAY
		    ) AS o ON CSD_DAY = SSD_DAY

	    ORDER BY REP_MONTH DESC, REP_DAY DESC

	    IF OBJECT_ID('tempdb..#month_stat') IS NOT NULL
		    DROP TABLE #month_stat
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
GRANT EXECUTE ON [dbo].[STAT_BY_MONTH] TO rl_stat_report;
GO
