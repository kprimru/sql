USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meeting].[ASSIGNED_MEETING_GET]
	@ID	UNIQUEIDENTIFIER
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
			a.ID_COMPANY, ID_OFFICE, ID_ASSIGNER, ID_PERSONAL, COMPANY_PERSONAL, EXPECTED_DATE, a.NOTE,
			ID_AREA, ID_STREET, HOME, ROOM, b.NOTE AS ADDR_NOTE, INCOMING, SPECIFY,
			(
				SELECT '{' + CONVERT(NVARCHAR(64), z.ID_PERSONAL) + '}' AS '@id'
				FROM Meeting.AssignedMeetingPersonal z
				WHERE z.ID_MEETING = a.ID
				FOR XML PATH('item'), ROOT('root')
			) AS PERSONAL_LIST,
			c.DATE AS NEXT_DATE
		FROM
			Meeting.AssignedMeeting a
			INNER JOIN Meeting.MeetingAddress b ON a.ID = b.ID_MEETING
			LEFT OUTER JOIN Client.CallDate c ON c.ID_COMPANY = a.ID_COMPANY
		WHERE a.ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Meeting].[ASSIGNED_MEETING_GET] TO rl_meeting_r;
GO
