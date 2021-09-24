USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DEMO_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@COMPANY	UNIQUEIDENTIFIER,
	@OFFICE		UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@NOTE		NVARCHAR(MAX)
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
		BEGIN TRAN CompanyDemo

		INSERT INTO Client.CompanyDemo(ID_MASTER, ID_COMPANY, ID_OFFICE, DATE, NOTE, STATUS, BDATE, EDATE, UPD_USER)
			SELECT ID, ID_COMPANY, ID_OFFICE, DATE, NOTE, 2, BDATE, EDATE, UPD_USER
			FROM Client.CompanyDemo
			WHERE ID = @ID

		UPDATE Client.CompanyDemo
		SET ID_OFFICE	= @OFFICE,
			DATE = @DATE,
			NOTE = @NOTE,
			BDATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID

		EXEC Client.COMPANY_REINDEX @COMPANY, NULL

		COMMIT TRAN CompanyDemo
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyDemo

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
GRANT EXECUTE ON [Client].[COMPANY_DEMO_UPDATE] TO rl_demo_w;
GO
