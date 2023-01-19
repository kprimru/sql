﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Book].[BOOK_PRICE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Book].[BOOK_PRICE_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Book].[BOOK_PRICE_UPDATE]
	@BP_ID		UNIQUEIDENTIFIER,
	@HLF_ID		UNIQUEIDENTIFIER,
	@BP_PRICE	MONEY,
	@BP_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @BP_ID_MASTER UNIQUEIDENTIFIER

	SELECT @BP_ID_MASTER = BP_ID_MASTER
	FROM	Book.BookPriceDetail
	WHERE	BP_ID = @BP_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'BOOK_PRICE', @BP_ID_MASTER, @OLD OUTPUT


	UPDATE	Book.BookPriceDetail
	SET		BP_ID_HALF	=	@HLF_ID,
			BP_PRICE	=	@BP_PRICE,
			BP_DATE		=	@BP_DATE
	WHERE	BP_ID		=	@BP_ID

	UPDATE	Book.BookPrice
	SET		BPMS_LAST	=	GETDATE()
	WHERE	BPMS_ID	=
		(
			SELECT	BP_ID_MASTER
			FROM	Book.BookPriceDetail
			WHERE	BP_ID	=	@BP_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'BOOK_PRICE', @BP_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'BOOK_PRICE', 'Редактирование', @BP_ID_MASTER, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Book].[BOOK_PRICE_UPDATE] TO rl_book_price_u;
GO
