USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_PROCESS_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_PROCESS_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@PERSONAL	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		SELECT
			a.PER_TYPE, a.PROC_TYPE, a.TYPE, a.NAME, a.SHORT, a.WBEGIN, a.WEND, a.CNT, b.NAME AS CHAR_NAME, b.CNT AS CHAR_CNT
		FROM
			(
				SELECT
					CASE
						WHEN TYPE IN (1, 5) THEN 1
						WHEN TYPE IN (2, 6) THEN 2
						ELSE 3
					END AS PER_TYPE,
					CASE
						WHEN TYPE IN (1, 2) THEN 1
						ELSE 2
					END AS PROC_TYPE, TYPE, c.NAME, b.SHORT, WBEGIN, WEND, COUNT(ID_COMPANY) AS CNT
				FROM
					Client.CompanyProcessJournal a
					INNER JOIN Personal.OfficePersonal b ON a.ID_PERSONAL = b.ID
					INNER JOIN Client.Availability c ON a.ID_AVAILABILITY = c.ID
					CROSS JOIN Common.WeekDates(@BEGIN, DATEADD(DAY, -1, @END))
				WHERE DATE >= WBEGIN AND DATE < DATEADD(DAY, 1, WEND)
					AND (b.ID = @PERSONAL OR @PERSONAL IS NULL)
					AND TYPE IN (1, 2, 5, 6)
				GROUP BY TYPE, c.NAME, b.SHORT, WBEGIN, WEND
			) AS a
			LEFT OUTER JOIN
			(
				SELECT
					CASE
						WHEN TYPE IN (1, 5) THEN 1
						WHEN TYPE IN (2, 6) THEN 2
						ELSE 3
					END AS PER_TYPE,
					CASE
						WHEN TYPE IN (1, 2) THEN 1
						ELSE 2
					END AS PROC_TYPE, TYPE, c.NAME, b.SHORT, WBEGIN, WEND, COUNT(ID_COMPANY) AS CNT
				FROM
					Client.CompanyProcessJournal a
					INNER JOIN Personal.OfficePersonal b ON a.ID_PERSONAL = b.ID
					INNER JOIN Client.Character c ON a.ID_CHARACTER = c.ID
					CROSS JOIN Common.WeekDates(@BEGIN, DATEADD(DAY, -1, @END))
				WHERE DATE >= WBEGIN AND DATE < DATEADD(DAY, 1, WEND)
					AND (b.ID = @PERSONAL OR @PERSONAL IS NULL)
					AND TYPE IN (1, 2, 5, 6)
				GROUP BY TYPE, c.NAME, b.SHORT, WBEGIN, WEND
			) AS b ON a.PER_TYPE = b.PER_TYPE
					AND a.PROC_TYPE = b.PROC_TYPE
					AND a.TYPE = b.TYPE
					AND a.WBEGIN = b.WBEGIN
					AND a.WEND = b.WEND
		ORDER BY a.WBEGIN, a.PER_TYPE, a.SHORT, a.TYPE, a.NAME, b.NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_REPORT] TO rl_company_journal_report;
GO
