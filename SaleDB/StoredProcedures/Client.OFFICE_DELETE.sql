﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[OFFICE_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[OFFICE_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[OFFICE_DELETE]
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

	BEGIN TRY
		BEGIN TRAN Office

		DECLARE @COMPANY UNIQUEIDENTIFIER

		SELECT @COMPANY = ID_COMPANY
		FROM Client.Office
		WHERE ID = @ID

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO Client.Office(ID_MASTER, ID_COMPANY, SHORT, NAME, MAIN, BDATE, EDATE, STATUS, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_COMPANY, SHORT, NAME, MAIN, BDATE, EDATE, 2, UPD_USER
			FROM Client.Office
			WHERE ID = @ID

		DECLARE @NEW_ID UNIQUEIDENTIFIER

		SELECT @NEW_ID = ID
		FROM @TBL

		INSERT INTO Client.OfficeAddress(ID_OFFICE, ID_AREA, ID_STREET, [INDEX], HOME, ROOM, NOTE)
			SELECT @NEW_ID, ID_AREA, ID_STREET, [INDEX], HOME, ROOM, NOTE
			FROM Client.OfficeAddress
			WHERE ID_OFFICE = @ID

		UPDATE Client.Office
		SET STATUS = 3,
			EDATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID

		EXEC Client.COMPANY_REINDEX @COMPANY, NULL

		COMMIT TRAN Office
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN Office

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
GRANT EXECUTE ON [Client].[OFFICE_DELETE] TO rl_office_d;
GO
