USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Meeting].[MEETING_STATUS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Meeting].[MEETING_STATUS_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Meeting].[MEETING_STATUS_SELECT]
	@FILTER	NVARCHAR(256),
	@RC		INT	= NULL OUTPUT
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
		SELECT	ID,	NAME
		FROM	Meeting.MeetingStatus
		WHERE	@FILTER IS NULL
				OR (NAME LIKE @FILTER)
		ORDER BY STATUS

		SET @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Meeting].[MEETING_STATUS_SELECT] TO rl_meeting_status_r;
GO
