USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Raw].[Income@Select?Files]
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
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY

        SELECT TOP (100)
            [Id]            = I.[Id],
            [FileName]      = I.[FileName],
            [Organization]  = O.[ORG_PSEDO]
        FROM [Raw].[Incomes]                    AS I
        INNER JOIN [dbo].[OrganizationTable]    AS O ON O.[ORG_ID] = I.[Organization_Id]
        ORDER BY [DateTime] DESC;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Raw].[Income@Select?Files] TO rl_income_w;
GO
