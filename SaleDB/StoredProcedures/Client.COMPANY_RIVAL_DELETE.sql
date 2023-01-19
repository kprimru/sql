﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_RIVAL_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_RIVAL_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_RIVAL_DELETE]
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
		BEGIN TRAN CompanyRival

		DECLARE @COMPANY UNIQUEIDENTIFIER

		SELECT @COMPANY = ID_COMPANY
		FROM Client.CompanyRival
		WHERE ID = @ID

		INSERT INTO Client.CompanyRival(ID_MASTER, ID_COMPANY, ID_OFFICE, ID_RIVAL, ID_VENDOR, INFO_DATE, NOTE, ACTIVE, STATUS, BDATE, EDATE, UPD_USER)
			SELECT ID, ID_COMPANY, ID_OFFICE, ID_RIVAL, ID_VENDOR, INFO_DATE, NOTE, ACTIVE, 2, BDATE, EDATE, UPD_USER
			FROM Client.CompanyRival
			WHERE ID = @ID

		UPDATE Client.CompanyRival
		SET STATUS = 3,
			EDATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID

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
GO
GRANT EXECUTE ON [Client].[COMPANY_RIVAL_DELETE] TO rl_rival_d;
GO
