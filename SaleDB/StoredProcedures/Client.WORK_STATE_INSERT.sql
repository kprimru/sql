USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[WORK_STATE_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[WORK_STATE_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[WORK_STATE_INSERT]
	@NAME	NVARCHAR(256),
	@GR     NVARCHAR(256),
	@SALE	BIT,
	@PHONE	BIT,
	@ARCH	BIT,
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
		INSERT INTO Client.WorkState(NAME, GR, SALE_AUTO, PHONE_AUTO, ARCHIVE_AUTO)
			OUTPUT inserted.ID INTO @TBL(ID)
			VALUES(@NAME, @GR, @SALE, @PHONE, @ARCH)

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
GRANT EXECUTE ON [Client].[WORK_STATE_INSERT] TO rl_work_state_w;
GO
