USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_ARCHIVE_DECLINE]
	@ID				UNIQUEIDENTIFIER
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
		BEGIN TRAN CompanyArchive

		DECLARE @COMPANY	UNIQUEIDENTIFIER

		SELECT @COMPANY = ID_COMPANY
		FROM Client.CompanyArchive
		WHERE ID = @ID

		INSERT INTO Client.CompanyArchive(ID_MASTER, ID_COMPANY, ID_POTENTIAL, ID_NEXT_MON, ID_AVAILABILITY, STATUS, BDATE, EDATE, UPD_USER)
			SELECT ID, ID_COMPANY, ID_POTENTIAL, ID_NEXT_MON, ID_AVAILABILITY, 2, BDATE, EDATE, UPD_USER
			FROM Client.CompanyArchive
			WHERE ID_COMPANY = @COMPANY
				AND STATUS = 1


		UPDATE Client.CompanyArchive
		SET STATUS = 5
		WHERE ID_COMPANY = @COMPANY
			AND STATUS = 1

		COMMIT TRAN CompanyArchive
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyArchive

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
GRANT EXECUTE ON [Client].[COMPANY_ARCHIVE_DECLINE] TO rl_archive_apply;
GO
