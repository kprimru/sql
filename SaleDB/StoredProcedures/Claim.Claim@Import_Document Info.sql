USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Claim].[Claim@Import?Document Info]
    @Number         Int,
    @CreateDateTime DateTime,
    @FIO            NVarChar(256),
    @CityName       NVarChar(256),
    @EMail          NVarChar(256),
    @Phone          NVarChar(256),
    @Actions        NVarChar(MAX)
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

        INSERT INTO [Claim].[Claims:Document Info]
                (
                    [Claim_Id],
                    [CreateDateTime],
                    [FIO],
                    [CityName],
                    [EMail],
                    [Phone],
                    [Actions]
                )
        SELECT
            C.[Id],
            @CreateDateTime,
            @FIO,
            @CityName,
            @EMail,
            @Phone,
            @Actions
        FROM [Claim].[Claims] AS C
        WHERE C.[Number] = @Number
            AND NOT EXISTS
            (
                SELECT *
                FROM [Claim].[Claims:Document Info] AS D
                WHERE   D.[Claim_Id] = C.[Id]
                    AND D.[CreateDateTime] = @CreateDateTime
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
