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
    @PageTitle      NVarChar(256) = NULL,
    @Section        NVarChar(256) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @RowIndex           Int,
        @Company_Id         UniqueIdentifier,
        @Personal_Id        UniqueIdentifier,
        @Id                 Int,
        @Type_Id            TinyInt,
        @StatusCode_New     VarChar(100),
        @Status_Id          TinyInt;

    DECLARE @Companies Table
    (
        [Row:Index] Int Identity(1,1),
        [Id]        UniqueIdentifier,
        [Name]      VarChar(500),
        [Number]    VarChar(100),
        PRIMARY KEY CLUSTERED ([Row:Index])
    );

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY

        IF @TypeCode = N'DOCUMENT-INFO' BEGIN
            EXEC [Claim].[Claim@Import?Document Info]
                @Number         = @Number,
                @CreateDateTime = @CreateDateTime,
                @FIO            = @FIO,
                @CityName       = @CityName,
                @EMail          = @EMail,
                @Phone          = @Phone,
                @Actions        = @Actions;


            EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

            RETURN;
        END;

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
                    [Section],
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
            @Section,
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

            INSERT INTO @Companies
            EXEC [Claim].[Claim@Seek?Company]
                @Id = @Id;

            SET @RowIndex = 0;

            WHILE (1 = 1) BEGIN
                SELECT TOP (1)
                    @RowIndex   = [Row:Index],
                    @Company_Id = [Id]
                FROM @Companies
                WHERE [Row:Index] > @RowIndex
                ORDER BY
                    [Row:Index];

                IF @@RowCount < 1
                    BREAK;

                EXEC [Client].[COMPANY_PERSONAL_INSERT]
                    @COMPANY    = @Company_Id,
                    @OFFICE     = NULL,
                    @SURNAME    = '',
                    @Name       = @FIO,
                    @PATRON     = '',
                    @POSITION   = NULL,
                    @NOTE       = @Special,
                    @EMAIL      = @Email,
                    @Mailing    = NULL,
                    @ID         = @Personal_Id OUTPUT;

                EXEC [Client].[COMPANY_PERSONAL_PHONE_INSERT]
                    @PERSONAL   = @Personal_Id,
                    @TYPE       = NULL,
                    @PHONE      = @Phone,
                    @PHONE_S    = @Phone,
                    @NOTE       = NULL;

                UPDATE [Client].[Company] SET
                    ID_SENDER   = 'F7B1B2FF-9E21-EB11-891B-0007E92AAFC5',
                    SENDER_NOTE = @Number
                WHERE ID = @Company_Id;

                INSERT INTO [Claim].[Claims:Companies]([Claim_Id], [Company_Id])
                SELECT @Id, @Company_Id;
            END;
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
