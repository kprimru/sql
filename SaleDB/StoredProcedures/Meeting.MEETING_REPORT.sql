USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Meeting].[MEETING_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Meeting].[MEETING_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [Meeting].[MEETING_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@PERSONAL	UNIQUEIDENTIFIER,
	@MANAGER	UNIQUEIDENTIFIER,
	@RESULT		NVARCHAR(MAX),
	@STATUS		INT,
	@ASSIGNER	UNIQUEIDENTIFIER,
	@RATE_BEGIN	INT = NULL,
	@RATE_END	INT = NULL,
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
			b.ID AS ID,
			b.NAME AS CO_NAME, b.NUMBER, EXPECTED_DATE, COMPANY_PERSONAL, a.NOTE AS MET_NOTE, SUCCESS_RATE,
			d.NAME AS AR_NAME,
			CASE DISPLAY
				WHEN 0 THEN f.PREFIX + f.NAME + ', '
				ELSE ''
			END + e.PREFIX + ' ' + e.NAME + ' ' + e.SUFFIX + ', ' + HOME + ' ' + ROOM AS MET_ADDR,
			g.NAME AS MET_RESULT, j.NAME AS STAT_NAME, h.SHORT AS PER_SHORT,
			REVERSE(STUFF(REVERSE(
				(
					SELECT y.SHORT + ', '
					FROM
						Meeting.AssignedMeetingPersonal z
						INNER JOIN Personal.OfficePersonal y ON z.ID_PERSONAL = y.ID
					WHERE z.ID_MEETING = a.ID
					ORDER BY SHORT FOR XML PATH('')
				)), 1, 2, '')) AS PER_WORK_SHORT,
			(
				SELECT TOP 1 NOTE
				FROM Meeting.ClientMeeting z
				WHERE z.ID_ASSIGNED = a.ID
					AND STATUS = 1
				ORDER BY DATE DESC
			) AS CLIENT_NOTE
			/*i.SHORT AS PER_WORK_SHORT,
			REVERSE(STUFF(REVERSE(
				(
					SELECT y.SHORT + ', '
					FROM
						Meeting.AssignedPersonal z
						INNER JOIN Office.Personal y ON z.ID_PERSONAL = y.ID
					WHERE z.ID_MEETING = a.ID
					ORDER BY SHORT FOR XML PATH('')
				)), 1, 2, '')) AS PER_WORK_NEW*/
		FROM
			Meeting.AssignedMeeting a
			INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
			LEFT OUTER JOIN Meeting.MeetingAddress c ON c.ID_MEETING = a.ID
			LEFT OUTER JOIN Address.Area d ON d.ID = c.ID_AREA
			LEFT OUTER JOIN Address.Street e ON e.ID = c.ID_STREET
			LEFT OUTER JOIN Address.City f ON f.ID = e.ID_CITY
			LEFT OUTER JOIN Meeting.MeetingResult g ON g.ID = a.ID_RESULT
			LEFT OUTER JOIN Personal.OfficePersonal h ON ID_ASSIGNER = h.ID
			LEFT OUTER JOIN Personal.OfficePersonal i ON ID_PERSONAL = i.ID
			LEFT OUTER JOIN Meeting.MeetingStatus j ON j.ID = a.ID_STATUS
		WHERE a.ID_MASTER IS NULL AND a.STATUS = 1 AND b.STATUS = 1
			AND (EXPECTED_DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (EXPECTED_DATE < @END OR @END IS NULL)
			AND (SUCCESS_RATE >= @RATE_BEGIN OR @RATE_BEGIN IS NULL)
			AND (SUCCESS_RATE <= @RATE_END OR @RATE_END IS NULL)
			AND (ID_RESULT IN (SELECT ID FROM Common.TableGUIDFromXML(@RESULT)) OR @RESULT IS NULL)
			AND
				(
					@PERSONAL IS NULL
					OR
					EXISTS
						(
							SELECT *
							FROM Meeting.AssignedMeetingPersonal z
							WHERE z.ID_MEETING = a.ID AND z.ID_PERSONAL = @PERSONAL
						)
				)
			AND
				(
					@MANAGER IS NULL
					OR
					EXISTS
						(
							SELECT *
							FROM Meeting.AssignedMeetingPersonal z
							WHERE z.ID_MEETING = a.ID
								AND z.ID_PERSONAL IN
									(
										SELECT ID
										FROM Personal.PersonalSlaveGet(@MANAGER)
									)
						)
				)
			--AND (a.ID_PERSONAL = @PERSONAL OR @PERSONAL IS NULL)
			--AND (a.ID_PERSONAL IN (SELECT ID FROM Personal.PersonalSlaveGet(@MANAGER)) OR @MANAGER IS NULL)
			AND (a.ID_ASSIGNER = @ASSIGNER OR @ASSIGNER IS NULL)
			AND (@STATUS IS NULL OR @STATUS = 0 OR @STATUS = -1 OR @STATUS = 1 AND j.VISIT = 1 OR @STATUS = 2 AND j.VISIT = 0)
		ORDER BY EXPECTED_DATE, PER_SHORT

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
GRANT EXECUTE ON [Meeting].[MEETING_REPORT] TO rl_meeting_report;
GO
