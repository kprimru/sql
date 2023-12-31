USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Book].[BOOK_PRICE_CHRONO]
	@HLF_ID			UNIQUEIDENTIFIER,
	@BP_PRICE		MONEY,
	@BP_DATE		SMALLDATETIME,
	@BP_ID_MASTER	UNIQUEIDENTIFIER,
	@BP_END			SMALLDATETIME,
	@BP_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'BOOK_PRICE', @BP_ID_MASTER, @OLD OUTPUT

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER


	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Book.BookPriceDetail
		SET		BP_END	=	@BP_END,
				BP_REF	=	2
		WHERE	BP_ID	=	@BP_ID

		UPDATE	Book.BookPrice
		SET		BPMS_LAST	=	GETDATE()
		WHERE	BPMS_ID		=	@BP_ID_MASTER

		INSERT INTO
				Book.BookPriceDetail(
					BP_ID_MASTER,
					BP_ID_HALF,
					BP_PRICE,
					BP_DATE
				)
		OUTPUT INSERTED.BP_ID INTO @TBL
		VALUES	(
					@BP_ID_MASTER,
					@HLF_ID,
					@BP_PRICE,
					@BP_DATE
				)

		SELECT	@BP_ID = ID
		FROM	@TBL
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION

	EXEC Common.PROTOCOL_VALUE_GET 'BOOK_PRICE', @BP_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'BOOK_PRICE', '��������������� ���������', @BP_ID_MASTER, @OLD, @NEW
END

GO
GRANT EXECUTE ON [Book].[BOOK_PRICE_CHRONO] TO rl_book_price_u;
GO
