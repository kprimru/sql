USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PERSONAL_DELETE]
	@ID		UNIQUEIDENTIFIER
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
		BEGIN TRAN ClientPersonal

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		DECLARE @NEW_ID UNIQUEIDENTIFIER

		INSERT INTO Client.CompanyPersonal(ID_MASTER, ID_COMPANY, ID_OFFICE, SURNAME, NAME, PATRON, ID_POSITION, NOTE, EMAIL, MAILING, BDATE, EDATE, STATUS, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_COMPANY, ID_OFFICE, SURNAME, NAME, PATRON, ID_POSITION, NOTE, EMAIL, MAILING, BDATE, EDATE, 2, UPD_USER
			FROM Client.CompanyPersonal
			WHERE ID = @ID

		SELECT @NEW_ID = ID
		FROM @TBL

		INSERT INTO Client.CompanyPersonalPhone(ID_PERSONAL, ID_TYPE, PHONE, PHONE_S, NOTE, STATUS)
			SELECT @NEW_ID, ID_TYPE, PHONE, PHONE_S, NOTE, 0
			FROM Client.CompanyPersonalPhone
			WHERE ID_PERSONAL = @ID

		UPDATE Client.CompanyPersonal
		SET STATUS = 3,
			EDATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID

		COMMIT TRAN ClientPersonal
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN ClientPersonal

		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PERSONAL_DELETE] TO rl_company_personal_d;
GO
