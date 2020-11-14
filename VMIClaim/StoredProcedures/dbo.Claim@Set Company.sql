USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Claim@Set Company]
    @Id             UniqueIdentifier,
    @Company_Id     UniqueIdentifier,
    @SalePersonal   VarChar(256),
    @Name           VarChar(512)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

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

        SELECT @SalePersonal_Id = ID
        FROM [SaleDB].[Personal.OfficePersonal]
        WHERE SHORT = @SalePersonal
            AND END_DATE IS NULL;

        SELECT
            @ClaimNum   = Cast(NUM AS VarChar(100)),
            @Email      = EMAIL,
            @FIO        = FIO,
            @Client     = CLIENT,
            @Special    = SPECIAL,
            @Phone      = Replace(PHONE, '+7', '8'),
            @WorkDate   = WORK_DATE,
            @WorkNote   = NOTE
        FROM dbo.Claim
        WHERE [Id] = @Id;

        -- если компании нет - создаем
        IF @Company_Id IS NULL BEGIN
            EXEC [SaleDB].[Client.COMPANY_NUMBER_GET]
                @NUM = @Number OUT;

            EXEC [SaleDB].[Client.COMPANY_INSERT]
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

            EXEC [SaleDB].[Client.COMPANY_PERSONAL_INSERT]
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

            EXEC [SaleDB].[Client.COMPANY_PERSONAL_PHONE_INSERT]
                @PERSONAL   = @Personal_Id,
                @TYPE       = NULL,
                @PHONE      = @Phone,
                @PHONE_S    = @Phone,
                @NOTE       = NULL;
        END;

        SET @Call_Id = (SELECT TOP (1) Call_Id FROM dbo.Claim WHERE ID = @Id);

        IF @WorkDate IS NOT NULL BEGIN
            -- записываем в звонки
            IF @Call_Id IS NULL
                EXEC [SaleDB].[Client.COMPANY_CALL_INSERT]
                    @COMPANY        = @Company_Id,
                    @OFFICE         = NULL,
                    @PERSONAL       = @SalePersonal_Id,
                    @CL_PERSONAL    = @FIO,
                    @DATE           = @WorkDate,
                    @NOTE           = @WorkNote,
                    @NEXT           = NULL,
                    @WARN_ID        = NULL,
                    @WARN_ACTION    = NULL,
                    @WARN_DATE      = NULL,
                    @WARN_NOTE      = NULL,
                    @CONTROL        = 0,
                    @DUTY           = NULL,
                    @ID             = @Call_Id OUTPUT;
            ELSE
                EXEC [SaleDB].[Client.COMPANY_CALL_UPDATE]
                    @ID             = @Call_Id,
                    @COMPANY        = @Company_Id,
                    @OFFICE         = NULL,
                    @PERSONAL       = @SalePersonal_Id,
                    @CL_PERSONAL    = @FIO,
                    @DATE           = @WorkDate,
                    @NOTE           = @WorkNote,
                    @NEXT           = NULL,
                    @WARN_ID        = NULL,
                    @WARN_ACTION    = NULL,
                    @WARN_DATE      = NULL,
                    @WARN_NOTE      = NULL,
                    @CONTROL        = 0,
                    @DUTY           = NULL;
        END;

        UPDATE dbo.Claim SET
            Company_Id  = @Company_Id
        WHERE ID = @Id
            AND Company_Id IS NULL;

        SET @Number = (SELECT TOP (1) [Number] FROM [SaleDB].[Client.Company] WHERE ID = @Company_Id);

        UPDATE dbo.Claim SET
            COMPANY  = @Number
        WHERE ID = @Id
            AND COMPANY IS NULL;

        IF @Call_Id IS NOT NULL
            UPDATE dbo.Claim SET
                Call_Id     = @Call_Id
            WHERE ID = @Id
                AND Call_Id IS NULL;

        IF @@TranCount > 0
            COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TranCount > 0
            ROLLBACK TRAN;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH;
END
GO
GRANT EXECUTE ON [dbo].[Claim@Set Company] TO rl_write;
GO