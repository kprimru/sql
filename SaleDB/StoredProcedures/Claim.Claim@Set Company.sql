USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Claim].[Claim@Set Company]
    @Id             Int,
    @Company_Id     UniqueIdentifier OUT,
    @Name           VarChar(512)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @ClaimNum           VarChar(100),
        @Email              VarChar(100),
        @FIO                VarChar(255),
        @Client             VarChar(255),
        @Phone              VarCHar(100),
        @Special            VarChar(1024),
        @WorkDate           SmallDateTime,
        @WorkNote           VarChar(Max),
        @Number             Int,
        @Call_Id            UniqueIdentifier,
        @SalePersonal_Id    UniqueIdentifier,
        @Personal_Id        UniqueIdentifier;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY
        SELECT
            @ClaimNum   = Cast([Number] AS VarChar(100)),
            @Email      = [EMail],
            @FIO        = [FIO],
            @Client     = [ClientName],
            @Special    = [Special],
            @Phone      = Replace([Phone], '+7', '8')
        FROM [Claim].[Claims] AS C
        WHERE [Id] = @Id;

        -- если компании нет - создаем
        IF @Company_Id IS NULL BEGIN
            EXEC [Client].[COMPANY_NUMBER_GET]
                @NUM = @Number OUT;

            EXEC [Client].[COMPANY_INSERT]
                @SHORT          = '',
                @NAME           = @Name,
                @NUMBER         = @Number,
                @PAY_CAT        = NULL,
                @WORK_STATE     = NULL,
                @POTENTIAL      = NULL,
                @ACTIVITY       = NULL,
                @ACTIVITY_NOTE  = NULL,
                @SENDER         = 'F7B1B2FF-9E21-EB11-891B-0007E92AAFC5',
                @SENDER_NOTE    = @ClaimNum,
                @NEXT_MON       = NULL,
                @WORK_DATE      = NULL,
                @DELETE_COMMENT = NULL,
                @AVAILABILITY   = NULL,
                @TAXING         = NULL,
                @WORK_STATUS    = NULL,
                @CHARACTER      = NULL,
                @REMOTE         = NULL,
                @EMAIL          = @Email,
                @BLACK_LIST     = NULL,
                @BLACK_NOTE     = NULL,
                @WORK_BEGIN     = NULL,
                @CARD           = NULL,
                @PAPER_CARD     = NULL,
                @TAXING_LIST    = NULL,
                @ACTIVITY_LIST  = NULL,
                @PROJECT        = NULL,
                @PROJECT_LIST   = NULL,
                @DEPO           = NULL,
                @DEPO_NUM       = NULL,
                @ID             = @Company_Id OUTPUT;
        END ELSE BEGIN
            UPDATE [Client].[Company] SET
                ID_SENDER   = 'F7B1B2FF-9E21-EB11-891B-0007E92AAFC5',
                SENDER_NOTE = @ClaimNum
            WHERE ID = @Company_Id;
        END;

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

        /*
        UPDATE [Claim].[Claims] SET
            Company_Id  = @Company_Id
        WHERE [Id] = @Id
            AND [Company_Id] IS NULL;
            */

        INSERT INTO [Claim].[Claims:Companies]([Claim_Id], [Company_Id])
        SELECT @Id, @Company_Id
        WHERE NOT EXISTS
            (
                SELECT *
                FROM [Claim].[Claims:Companies]
                WHERE [Claim_Id] = @Id
                    AND [Company_Id] = @Company_Id
            );

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        IF @@TranCount > 0
            ROLLBACK TRAN;

        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claim@Set Company] TO rl_claim_set_company;
GO
