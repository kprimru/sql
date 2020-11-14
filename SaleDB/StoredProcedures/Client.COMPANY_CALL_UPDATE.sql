USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_CALL_UPDATE]
	@ID				UNIQUEIDENTIFIER,
	@COMPANY		UNIQUEIDENTIFIER,
	@OFFICE			UNIQUEIDENTIFIER,
	@PERSONAL		UNIQUEIDENTIFIER,
	@CL_PERSONAL	VARCHAR(512),
	@DATE			SMALLDATETIME,
	@NOTE			NVARCHAR(MAX),
	@NEXT			SMALLDATETIME = NULL,
	@WARN_ID		UNIQUEIDENTIFIER = NULL,
	@WARN_ACTION	INT = NULL,
	@WARN_DATE		SMALLDATETIME = NULL,
	@WARN_NOTE		NVARCHAR(MAX) = NULL,
	@CONTROL		BIT = 0,
	@DUTY			BIT = NULL
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
		INSERT INTO Client.Call(ID_MASTER, ID_COMPANY, ID_OFFICE, ID_PERSONAL, CL_PERSONAL, DATE, NOTE, STATUS, BDATE, EDATE, UPD_USER, CONTROL, DUTY)
			SELECT ID, ID_COMPANY, ID_OFFICE, ID_PERSONAL, CL_PERSONAL, DATE, NOTE, 2, BDATE, EDATE, UPD_USER, CONTROL, DUTY
			FROM Client.Call
			WHERE ID = @ID

		UPDATE Client.Call
		SET ID_OFFICE	=	@OFFICE,
			ID_PERSONAL	=	@PERSONAL,
			CL_PERSONAL	=	@CL_PERSONAL,
			DATE		=	@DATE,
			NOTE		=	@NOTE,
			CONTROL		=	@CONTROL,
			DUTY		=	@DUTY,
			BDATE		=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID

		EXEC Client.CALL_DATE_CHANGE @COMPANY, @NEXT

		EXEC Client.COMPANY_REINDEX @COMPANY, NULL
	END TRY
	BEGIN CATCH
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
GRANT EXECUTE ON [Client].[COMPANY_CALL_UPDATE] TO rl_call_w;
GO