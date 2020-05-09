USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[PAY_CATEGORY_INSERT]
	@NAME	NVARCHAR(128),
	@SHORT	NVARCHAR(64),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE
		(
			ID	UNIQUEIDENTIFIER
		)

	BEGIN TRY
		INSERT INTO Client.PayCategory(NAME, SHORT, GR, ORD)
			OUTPUT inserted.ID INTO @TBL(ID)
			SELECT @NAME, @SHORT, @SHORT, (SELECT MAX(ORD) FROM Client.PayCategory) + 10

		SELECT @ID = ID FROM @TBL
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
GRANT EXECUTE ON [Client].[PAY_CATEGORY_INSERT] TO rl_pay_category_w;
GO