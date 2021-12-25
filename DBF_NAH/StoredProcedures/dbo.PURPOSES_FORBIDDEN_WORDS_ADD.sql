USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PURPOSES_FORBIDDEN_WORDS_ADD]
    @Mask           VarChar(256),
    @IsActive       Bit = 1,
    @ReturnValue    Bit = 1
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        INSERT INTO dbo.PurposesForbiddenWords(Mask, IsActive)
        VALUES (@Mask, @IsActive);

        IF @ReturnValue = 1
            SELECT SCOPE_IDENTITY() AS NEW_IDEN;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PURPOSES_FORBIDDEN_WORDS_ADD] TO rl_purposes_forbidden_words_w;
GO
