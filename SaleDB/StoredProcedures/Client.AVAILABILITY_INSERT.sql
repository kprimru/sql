USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[AVAILABILITY_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[AVAILABILITY_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[AVAILABILITY_INSERT]
	@NAME	NVARCHAR(256),
	@GR     NVARCHAR(256),
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
		INSERT INTO Client.Availability(NAME, GR)
			OUTPUT inserted.ID INTO @TBL(ID)
			VALUES(@NAME, @GR)

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
GRANT EXECUTE ON [Client].[AVAILABILITY_INSERT] TO rl_availability_w;
GO
