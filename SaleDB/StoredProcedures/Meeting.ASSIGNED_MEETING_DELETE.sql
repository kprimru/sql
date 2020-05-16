USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meeting].[ASSIGNED_MEETING_DELETE]
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
		DECLARE @COMPANY UNIQUEIDENTIFIER

		SELECT @COMPANY = ID_COMPANY
		FROM Meeting.AssignedMeeting
		WHERE ID = @ID

		DECLARE @TBL TABLE (ID	UNIQUEIDENTIFIER)

		INSERT INTO Meeting.AssignedMeeting(ID_MASTER, ID_COMPANY, ID_OFFICE, ID_CALL, ID_ASSIGNER, ID_PERSONAL, COMPANY_PERSONAL, EXPECTED_DATE, NOTE, ID_RESULT, SUCCESS_RATE, STATUS, BDATE, EDATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_COMPANY, ID_OFFICE, ID_CALL, ID_ASSIGNER, ID_PERSONAL, COMPANY_PERSONAL, EXPECTED_DATE, NOTE, ID_RESULT, SUCCESS_RATE, 2, BDATE, EDATE, UPD_USER
			FROM Meeting.AssignedMeeting
			WHERE ID = @ID

		DECLARE @NEWID	UNIQUEIDENTIFIER

		SELECT @NEWID = ID FROM @TBL

		INSERT INTO Meeting.MeetingAddress(ID_MEETING, ID_AREA, ID_STREET, HOME, ROOM, NOTE)
			SELECT @NEWID, ID_AREA, ID_STREET, HOME, ROOM, NOTE
			FROM Meeting.MeetingAddress
			WHERE ID_MEETING = @ID

		UPDATE Meeting.AssignedMeeting
		SET STATUS = 3,
			EDATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID

		EXEC Client.COMPANY_REINDEX @COMPANY, NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Meeting].[ASSIGNED_MEETING_DELETE] TO rl_meeting_d;
GO