USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_FILES_DELETE]
	@ID			UNIQUEIDENTIFIER
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
		BEGIN TRAN CompanyFiles

		DECLARE @COMPANY UNIQUEIDENTIFIER

		SELECT @COMPANY = ID_COMPANY
		FROM Client.CompanyFiles
		WHERE ID = @ID

		INSERT INTO Client.CompanyFiles(ID_MASTER, ID_COMPANY, FILE_NAME, FILE_DATA, FILE_NOTE, STATUS, BDATE, EDATE, UPD_USER)
			SELECT ID, ID_COMPANY, FILE_NAME, FILE_DATA, FILE_NOTE, 2, BDATE, EDATE, UPD_USER
			FROM Client.CompanyFiles
			WHERE ID = @ID

		UPDATE Client.CompanyFiles
		SET STATUS = 3,
			EDATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID

		--EXEC Client.COMPANY_REINDEX @COMPANY, NULL

		COMMIT TRAN CompanyFiles
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyFiles

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
GRANT EXECUTE ON [Client].[COMPANY_FILES_DELETE] TO rl_company_files_d;
GO
