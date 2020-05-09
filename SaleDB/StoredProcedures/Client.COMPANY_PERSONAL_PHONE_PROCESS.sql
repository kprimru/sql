USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PERSONAL_PHONE_PROCESS]
	@ID			UNIQUEIDENTIFIER,
	@PERSONAL	UNIQUEIDENTIFIER,
	@TYPE		UNIQUEIDENTIFIER,
	@PHONE		NVARCHAR(128),
	@PHONE_S	NVARCHAR(64),
	@NOTE		NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @ID IS NULL
			EXEC Client.COMPANY_PERSONAL_PHONE_INSERT @PERSONAL, @TYPE, @PHONE, @PHONE_S, @NOTE
		ELSE
			EXEC Client.COMPANY_PERSONAL_PHONE_UPDATE @ID, @PERSONAL, @TYPE, @PHONE, @PHONE_S, @NOTE
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
GRANT EXECUTE ON [Client].[COMPANY_PERSONAL_PHONE_PROCESS] TO rl_company_personal_w;
GO