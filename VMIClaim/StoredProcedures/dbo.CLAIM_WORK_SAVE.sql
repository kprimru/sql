USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLAIM_WORK_SAVE]
	@CLAIM		    UNIQUEIDENTIFIER,
	@DATE		    DATETIME,
	@STATUS		    UNIQUEIDENTIFIER,
	@TOTAL_NOTE	    NVARCHAR(MAX),
	@DISTR		    NVARCHAR(256),
	@MEETING	    BIT = NULL,
	@OFFER		    BIT = NULL,
	@COMPANY	    INT = NULL,
	@MAILING	    BIT = NULL,
	@SalePersonal   VarChar(256) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

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
            @Company_Id         UniqueIdentifier,
            @SalePersonal_Id    UniqueIdentifier,
            @Personal_Id        UniqueIdentifier;

	BEGIN TRY
		BEGIN TRAN;

		UPDATE dbo.Claim
	    SET ID_STATUS	=	@STATUS,
		    NOTE		=	@TOTAL_NOTE,
		    DISTR		=	@DISTR,
		    WORK_DATE	=	@DATE,
		    MEETING		=	@MEETING,
		    OFFER		=	@OFFER,
		    COMPANY		=	@COMPANY,
		    MAILING		=	@MAILING
	    WHERE ID = @CLAIM

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
        WHERE [Id] = @CLAIM;

        SELECT @SalePersonal_Id = ID
        FROM [SaleDB].[Personal.OfficePersonal]
        WHERE SHORT = @SalePersonal
            AND END_DATE IS NULL;

        SET @Call_Id = (SELECT TOP (1) Call_Id FROM dbo.Claim WHERE ID = @CLAIM);
        SET @Company_Id = (SELECT TOP (1) Company_Id FROM dbo.Claim WHERE ID = @CLAIM);

        IF @WorkDate IS NOT NULL AND @Company_Id IS NOT NULL BEGIN
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

        IF @Call_Id IS NOT NULL
            UPDATE dbo.Claim SET
                Call_Id     = @Call_Id
            WHERE ID = @CLAIM
                AND Call_Id IS NULL;

	    IF @@TranCount > 0
	        COMMIT TRAN;
	END TRY
	BEGIN CATCH
	    IF @@TranCount > 0
	        ROLLBACK TRAN;

	    EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLAIM_WORK_SAVE] TO rl_write;
GO