USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Raw].[Income_Detail@Set?Not For Import]
    @Id                 BigInt,
    @Value              Bit
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

        UPDATE [Raw].[Incomes:Details] SET
            [NotForImport] = @Value
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
GRANT EXECUTE ON [Raw].[Income_Detail@Set?Not For Import] TO rl_income_w;
GO
