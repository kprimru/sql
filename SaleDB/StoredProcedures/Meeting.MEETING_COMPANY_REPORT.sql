USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meeting].[MEETING_COMPANY_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@RC			INT = NULL OUTPUT
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
		SET @END = DATEADD(DAY, 1, @END)

		SELECT
			a.ID AS CO_ID, a.NAME,
			b.SUCCESS_RATE, b.STAT_NAME, b.RES_NAME,
			b.DATE
		FROM
			(
				SELECT DISTINCT ID, NAME
				FROM Client.Company a
				WHERE a.STATUS = 1
					AND EXISTS
						(
							SELECT *
							FROM Meeting.AssignedMeeting b
							WHERE a.ID = b.ID_COMPANY
								AND (EXPECTED_DATE >= @BEGIN OR @BEGIN IS NULL)
								AND (EXPECTED_DATE < @END OR @END IS NULL)
						)
			) AS a
			CROSS APPLY
			(
				SELECT TOP 1 Common.DateOf(EXPECTED_DATE) AS DATE, SUCCESS_RATE, c.NAME AS RES_NAME, d.NAME AS STAT_NAME
				FROM
					Meeting.AssignedMeeting b
					LEFT OUTER JOIN Meeting.MeetingResult c ON b.ID_RESULT = c.ID
					LEFT OUTER JOIN Meeting.MeetingStatus d ON b.ID_STATUS = d.ID
				WHERE a.ID = b.ID_COMPANY
					AND b.STATUS = 1
				ORDER BY BDATE DESC
			) b
		ORDER BY DATE, NAME

		SELECT @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Meeting].[MEETING_COMPANY_REPORT] TO rl_meeting_report;
GO
