USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Client].[COMPANY_PROCESS_GET]
	@ID		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY		
		SELECT
			(
				SELECT ID_PERSONAL
				FROM Client.CompanyProcess
				WHERE ID_COMPANY = @ID
					AND PROCESS_TYPE = N'PHONE'
					AND EDATE IS NULL
			) AS ID_PHONE,
			(
				SELECT ID_PERSONAL
				FROM Client.CompanyProcess
				WHERE ID_COMPANY = @ID
					AND PROCESS_TYPE = N'SALE'
					AND EDATE IS NULL
			) AS ID_SALE
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