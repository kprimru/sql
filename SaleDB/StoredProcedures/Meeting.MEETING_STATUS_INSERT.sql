USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meeting].[MEETING_STATUS_INSERT]
	@NAME	NVARCHAR(256),
	@STATUS	TINYINT,
	@VISIT	BIT,
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

	DECLARE @TBL TABLE
		(
			ID	UNIQUEIDENTIFIER
		)

	BEGIN TRY
		INSERT INTO Meeting.MeetingStatus(NAME, STATUS, VISIT)
			OUTPUT inserted.ID INTO @TBL(ID)
			VALUES(@NAME, @STATUS, @VISIT)

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Meeting].[MEETING_STATUS_INSERT] TO rl_meeting_status_w;
GO