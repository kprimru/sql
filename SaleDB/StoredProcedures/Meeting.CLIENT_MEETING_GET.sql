USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meeting].[CLIENT_MEETING_GET]
	@ID			UNIQUEIDENTIFIER,
	@ASSIGNED	UNIQUEIDENTIFIER = NULL
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
		IF @ID IS NOT NULL
			SELECT
				ID, DATE, ID_PERSONAL, ID_RESULT, NOTE,
				(
					SELECT TOP 1 SUCCESS_RATE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS SUCCESS_RATE,
				(
					SELECT TOP 1 a.ID_RESULT
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_RES,
				(
					SELECT TOP 1 a.ID_STATUS
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_STATUS,
				(
					SELECT TOP 1 a.STATUS_NOTE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_STATUS_NOTE,
				(
					SELECT DATE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Client.CallDate z ON z.ID_COMPANY = a.ID_COMPANY
					WHERE a.ID = @ASSIGNED
				) AS NEXT_DATE
			FROM
				Meeting.ClientMeeting t
			WHERE ID = @ID
		ELSE
			SELECT
				CONVERT(UNIQUEIDENTIFIER, NULL) AS ID,
				Common.DateOf(GETDATE()) AS DATE,
				CONVERT(UNIQUEIDENTIFIER, NULL) AS ID_PERSONAL,
				CONVERT(UNIQUEIDENTIFIER, NULL)ID_RESULT,
				CONVERT(NVARCHAR(MAX), '') AS NOTE,
				(
					SELECT TOP 1 SUCCESS_RATE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS SUCCESS_RATE,
				(
					SELECT TOP 1 a.ID_RESULT
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_RES,
				(
					SELECT TOP 1 a.ID_STATUS
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_STATUS,
				(
					SELECT TOP 1 a.STATUS_NOTE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_STATUS_NOTE,
				(
					SELECT DATE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Client.CallDate z ON z.ID_COMPANY = a.ID_COMPANY
					WHERE a.ID = @ASSIGNED
				) AS NEXT_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Meeting].[CLIENT_MEETING_GET] TO rl_meeting_r;
GRANT EXECUTE ON [Meeting].[CLIENT_MEETING_GET] TO rl_meeting_result;
GO
