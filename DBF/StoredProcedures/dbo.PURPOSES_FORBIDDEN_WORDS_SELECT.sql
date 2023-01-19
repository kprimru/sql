USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PURPOSES_FORBIDDEN_WORDS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PURPOSES_FORBIDDEN_WORDS_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[PURPOSES_FORBIDDEN_WORDS_SELECT]
    @Active             Bit = NULL
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

        SELECT [Id], [Mask]
        FROM dbo.PurposesForbiddenWords
        WHERE [IsActive] = IsNull(@Active, [IsActive])
        ORDER BY [Mask];

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PURPOSES_FORBIDDEN_WORDS_SELECT] TO rl_purposes_forbidden_words_r;
GO
