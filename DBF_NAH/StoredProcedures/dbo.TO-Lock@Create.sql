USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TO-Lock@Create]
    @To_Id          Int,
    @ExpireDate     SmallDateTime
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @RowIndex       SmallInt;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY
        EXEC [dbo].[TO-Lock@Clear] @TO_Id = @TO_Id;

        SELECT TOP (1)
            @RowIndex = [Row:Index] + 1
        FROM [dbo].[TO:Locks]
        WHERE [TO_Id] = @TO_Id
        ORDER BY [Row:Index] DESC;

        IF @RowIndex IS NULL
            SET @RowIndex = 1

        INSERT INTO [dbo].[TO:Locks]([TO_Id], [Row:Index], [DateFrom], [ExpireDate])
        SELECT @TO_Id, @RowIndex, GetDate(), @ExpireDate;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END

GO
