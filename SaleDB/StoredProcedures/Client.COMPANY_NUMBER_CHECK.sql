USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_NUMBER_CHECK]
	@ID				UNIQUEIDENTIFIER,
	@NUMBER			INT
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
		IF @ID IS NULL
			SELECT ID, NUMBER
			FROM Client.CompanyNumberView WITH(NOEXPAND)
			WHERE NUMBER = @NUMBER
		ELSE
			SELECT ID, NUMBER
			FROM Client.CompanyNumberView WITH(NOEXPAND)
			WHERE NUMBER = @NUMBER
				AND ID <> @ID
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN Company

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
GRANT EXECUTE ON [Client].[COMPANY_NUMBER_CHECK] TO rl_company_w;
GO