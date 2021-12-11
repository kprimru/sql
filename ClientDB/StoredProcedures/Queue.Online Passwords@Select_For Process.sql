USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Queue].[Online Passwords@Select?For Process]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Queue].[Online Passwords@Select?For Process]  AS SELECT 1')
GO
ALTER PROCEDURE [Queue].[Online Passwords@Select?For Process]
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

        SELECT [Id], [FileName]
        FROM [Queue].[Online Passwords] AS OP
        WHERE OP.[ProcessDateTime] IS NULL;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
