USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PURPOSES_FORBIDDEN_WORDS_GET]
    @Id             SmallInt
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

        SELECT [Mask], [IsActive]
        FROM dbo.PurposesForbiddenWords
        WHERE [Id] = @Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PURPOSES_FORBIDDEN_WORDS_GET] TO rl_purposes_forbidden_words_r;
GO
