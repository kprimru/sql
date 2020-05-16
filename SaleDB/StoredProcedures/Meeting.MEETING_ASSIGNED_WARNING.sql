USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meeting].[MEETING_ASSIGNED_WARNING]
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
		SELECT b.ID, b.NAME, b.NUMBER, a.EXPECTED_DATE, c.SHORT, d.NAME
		FROM
			Meeting.AssignedMeeting a
			INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
			INNER JOIN Personal.OfficePersonal c ON c.ID = a.ID_ASSIGNER
			LEFT OUTER JOIN Meeting.MeetingStatus d ON d.ID = a.ID_STATUS
		WHERE b.STATUS = 1 --AND a.ID_PERSONAL IS NULL
			AND NOT EXISTS
				(
					SELECT *
					FROM Meeting.AssignedMeetingPersonal z
					WHERE z.ID_MEETING = a.ID
				)
			AND a.STATUS = 1
			AND a.ID_MASTER IS NULL
			AND a.ID_PARENT IS NULL
			AND (d.STATUS IS NULL OR d.STATUS IN (0, 3))

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Meeting].[MEETING_ASSIGNED_WARNING] TO rl_warning_meeting_assigned;
GO