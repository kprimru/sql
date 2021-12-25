USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meeting].[CLIENT_MEETING_SELECT]
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
		SELECT a.ID, DATE, c.SHORT, b.NAME, NOTE
		FROM
			Meeting.ClientMeeting a
			INNER JOIN Personal.OfficePersonal c ON c.ID = a.ID_PERSONAL
			LEFT OUTER JOIN Meeting.MeetingResult b ON a.ID_RESULT = b.ID
		WHERE ID_ASSIGNED = @ID
		ORDER BY DATE DESC

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
GRANT EXECUTE ON [Meeting].[CLIENT_MEETING_SELECT] TO rl_meeting_r;
GO
