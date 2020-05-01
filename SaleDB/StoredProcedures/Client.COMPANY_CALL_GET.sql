USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_CALL_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT	a.ID, ID_OFFICE, ID_PERSONAL, CL_PERSONAL, a.DATE, NOTE, b.DATE AS NEXT_DATE, CONTROL, DUTY
		FROM
			Client.Call a
			LEFT OUTER JOIN Client.CallDate b ON a.ID_COMPANY = b.ID_COMPANY
		WHERE a.ID	=	@ID
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
GRANT EXECUTE ON [Client].[COMPANY_CALL_GET] TO rl_call_r;
GO