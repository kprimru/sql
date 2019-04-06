USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sale].[COMPANY_SALE_DISTR_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@SYSTEM		UNIQUEIDENTIFIER,
	@NET		UNIQUEIDENTIFIER,
	@COUNT		SMALLINT
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY
		INSERT INTO Sale.SaleDistr(ID_SALE, ID_SYSTEM, ID_NET, CNT)
			VALUES(@ID, @SYSTEM, @NET, @COUNT)
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