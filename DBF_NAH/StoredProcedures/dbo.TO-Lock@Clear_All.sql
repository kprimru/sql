USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TO-Lock@Clear?All]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TO-Lock@Clear?All]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[TO-Lock@Clear?All]
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
        UPDATE [dbo].[TO:Locks] SET
            [DateTO]            = GetDate(),
            [FinishUserName]    = Original_Login(),
            [FinishDateTime]    = GetDate()
        WHERE [DateTo] IS NULL
            AND [ExpireDate] < GetDate();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END

GO
