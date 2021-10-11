USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Queue].[Online Passwords@Import]
    @Files  VarChar(Max)
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

        INSERT INTO [Queue].[Online Passwords]([FileName], [CreateDateTime])
        SELECT F.[ID], GetDate()
        FROM dbo.TableStringNewFromXML(@Files) AS F
        WHERE NOT EXISTS
            (
                SELECT *
                FROM [Queue].[Online Passwords]
                WHERE [FileName] = F.[ID]
            );

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
