USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_RIVAL_INSERT]
	@COMPANY	UNIQUEIDENTIFIER,
	@OFFICE		UNIQUEIDENTIFIER,
	@RIVAL		UNIQUEIDENTIFIER,
	@INFO_DATE	SMALLDATETIME,
	@NOTE		NVARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT,
	@VENDOR		UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	BEGIN TRY
		BEGIN TRAN CompanyRival

		INSERT INTO Client.CompanyRival(ID_COMPANY, ID_OFFICE, ID_RIVAL, ID_VENDOR, INFO_DATE, NOTE)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@COMPANY, @OFFICE, @RIVAL, @VENDOR, @INFO_DATE, @NOTE)

		SELECT @ID = ID FROM @TBL

		UPDATE Client.Company
		SET WORK_DATE = Common.DateOf(GETDATE())
		WHERE ID = @COMPANY

		EXEC Client.COMPANY_REINDEX @COMPANY, NULL

		COMMIT TRAN CompanyRival
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyRival

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
GRANT EXECUTE ON [Client].[COMPANY_RIVAL_INSERT] TO rl_rival_w;
GO