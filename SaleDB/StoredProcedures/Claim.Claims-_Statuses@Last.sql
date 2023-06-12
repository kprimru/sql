USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[Claims->Statuses@Last]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[Claims->Statuses@Last]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[Claims->Statuses@Last]
    @Last   DateTime OUTPUT
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
        SELECT  @LAST = MAX(UpdDate)
        FROM    [Claim].[Claims->Statuses];

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claims->Statuses@Last] TO rl_claim_status_r;
GO
