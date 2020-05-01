USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [System].[CATEGORY_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(128),
	@SHORT	NVARCHAR(64)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE	System.Category
		SET		NAME	=	@NAME,
				SHORT	=	@SHORT,
				LAST	=	GETDATE()
		WHERE	ID		=	@ID
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
GRANT EXECUTE ON [System].[CATEGORY_UPDATE] TO rl_sys_category_w;
GO