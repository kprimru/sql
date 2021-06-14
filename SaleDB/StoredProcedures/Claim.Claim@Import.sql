USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Claim].[Claim@Import]
    @TypeCode       VarChar(100),
    @Number         Int,
    @CreateDateTime DateTime,
    @FIO            NVarChar(256),
    @ClientName     NVarChar(256),
    @CityName       NVarChar(256),
    @EMail          NVarChar(256),
    @Phone          NVarChar(256),
    @Special        NVarChar(MAX) = NULL,
    @Actions        NVarChar(MAX) = NULL,
    @PageURL        NVarChar(256) = NULL,
    @PageTitle      NVarChar(256) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @Id                 Int,
        @Type_Id            TinyInt,
        @StatusCode_New     VarChar(100),
        @Status_Id          TinyInt;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY
        SET @StatusCode_New = 'NEW';
        SET @Type_Id = (SELECT [Id] FROM [Claim].[Claims->Types] WHERE [Code] = @TypeCode);
        SET @Status_Id = (SELECT [Id] FROM [Claim].[Claims->Statuses] WHERE [Code] = @StatusCode_New);

        INSERT INTO [Claim].[Claims]
                (
                    [Type_Id],
                    [Number],
                    [CreateDateTime],
                    [FIO],
                    [ClientName],
                    [CityName],
                    [EMail],
                    [Phone],
                    [Special],
                    [Actions],
                    [PageURL],
                    [PageTitle],
                    [Status_Id]
                )
        SELECT
            @Type_Id,
            @Number,
            @CreateDateTime,
            @FIO,
            @ClientName,
            @CityName,
            @EMail,
            @Phone,
            @Special,
            @Actions,
            @PageURL,
            @PageTitle,
            @Status_Id
        WHERE NOT EXISTS
            (
                SELECT *
                FROM [Claim].[Claims]
                WHERE   [Type_Id] = @Type_Id
                    AND [Number] = @Number
                    AND [CreateDateTime] = @CreateDateTime
            );

        IF @@RowCount != 0 BEGIN
            SET @Id = Scope_Identity();

            INSERT INTO [Claim].[Claims:Statuses]([Claim_Id], [Index], [DateTime], [Status_Id])
            SELECT @Id, 1, GetDate(), @Status_Id;
        END;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
