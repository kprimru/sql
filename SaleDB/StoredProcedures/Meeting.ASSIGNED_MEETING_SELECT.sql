USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Meeting].[ASSIGNED_MEETING_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Meeting].[ASSIGNED_MEETING_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Meeting].[ASSIGNED_MEETING_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@RC		INT				=	NULL OUTPUT
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
			a.ID, a.ID_PARENT, EXPECTED_DATE, b.SHORT, b.NAME,
			/*c.SHORT AS PERS,*/
			REVERSE(STUFF(REVERSE(
				(
					SELECT y.SHORT + ', '
					FROM
						Meeting.AssignedMeetingPersonal z
						INNER JOIN Personal.OfficePersonal y ON z.ID_PERSONAL = y.ID
					WHERE z.ID_MEETING = a.ID
					ORDER BY SHORT FOR XML PATH('')
				)), 1, 2, '')) AS PERS,
			e.SHORT AS ASSIGNER, d.NAME AS RESULT, SUCCESS_RATE,
			CASE ISNULL(DISPLAY, 1) WHEN 1 THEN ISNULL(i.NAME + ', ', '') ELSE '' END + ISNULL(h.PREFIX + ' ', '') +  ISNULL(h.NAME, '') + ISNULL(' ' + h.SUFFIX, '') AS ST_NAME,
			g.NAME AS AR_NAME, INCOMING, j.NAME AS STAT_NAME
		FROM
			Meeting.AssignedMeeting a
			--LEFT OUTER JOIN Personal.OfficePersonal c ON c.ID = a.ID_PERSONAL
			LEFT OUTER JOIN Client.Office b ON a.ID_OFFICE = b.ID
			LEFT OUTER JOIN Meeting.MeetingResult d ON d.ID = a.ID_RESULT
			LEFT OUTER JOIN Personal.OfficePersonal e ON e.ID = a.ID_ASSIGNER
			LEFT OUTER JOIN Meeting.MeetingAddress f ON f.ID_MEETING = a.ID
			LEFT OUTER JOIN Address.Area g ON g.ID = f.ID_AREA
			LEFT OUTER JOIN Address.Street h ON h.ID = f.ID_STREET
			LEFT OUTER JOIN Address.City i ON i.ID = h.ID_CITY
			LEFT OUTER JOIN Meeting.MeetingStatus j ON j.ID = a.ID_STATUS
		WHERE a.ID_COMPANY = @ID AND a.ID_MASTER IS NULL AND a.STATUS = 1
		ORDER BY EXPECTED_DATE DESC

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
GRANT EXECUTE ON [Meeting].[ASSIGNED_MEETING_SELECT] TO rl_meeting_r;
GO
