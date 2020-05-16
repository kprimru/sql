USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PERSONAL_INSERT]
	@COMPANY	UNIQUEIDENTIFIER,
	@OFFICE		UNIQUEIDENTIFIER,
	@SURNAME	NVARCHAR(128),
	@NAME		NVARCHAR(128),
	@PATRON		NVARCHAR(128),
	@POSITION	UNIQUEIDENTIFIER,
	@NOTE		NVARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT,
	@EMAIL		NVARCHAR(256) = NULL,
	@MAILING	BIT = NULL
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

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	BEGIN TRY
		BEGIN TRAN CompanyPersonal

		INSERT INTO Client.CompanyPersonal(ID_COMPANY, ID_OFFICE, SURNAME, NAME, PATRON, ID_POSITION, NOTE, EMAIL, MAILING)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@COMPANY, @OFFICE, @SURNAME, @NAME, @PATRON, @POSITION, @NOTE, @EMAIL, @MAILING)

		SELECT @ID = ID
		FROM @TBL

		COMMIT TRAN CompanyPersonal
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyPersonal

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
GRANT EXECUTE ON [Client].[COMPANY_PERSONAL_INSERT] TO rl_company_personal_w;
GO