USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Income].[INCOME_BOOK_INSERT]
	@IB_DATE		SMALLDATETIME,
	@IB_ID_MASTER	UNIQUEIDENTIFIER,
	@IB_REPAY		BIT,
	@CL_ID			UNIQUEIDENTIFIER,
	@VD_ID			UNIQUEIDENTIFIER,
	@IB_PRICE		MONEY,
	@IB_SUM			MONEY,
	@IB_COUNT		TINYINT,
	@IB_FULL_PAY	SMALLDATETIME,
	@HLF_ID			UNIQUEIDENTIFIER,
	@PER_ID			UNIQUEIDENTIFIER,
	@IB_LOCK		BIT,
	@IB_NOTE		VARCHAR(250),
	@IB_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'INCOME_BOOK', NULL, @OLD OUTPUT

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	INSERT INTO Income.IncomeBook(
			IB_DATE, IB_ID_MASTER, IB_REPAY, IB_ID_CLIENT,
			IB_ID_VENDOR, IB_PRICE, IB_SUM, IB_COUNT, IB_FULL_PAY,
			IB_ID_HALF, IB_ID_PERSONAL, IB_LOCK, IB_NOTE
			)
	OUTPUT INSERTED.IB_ID INTO @TBL
	VALUES(
			@IB_DATE, @IB_ID_MASTER, ISNULL(@IB_REPAY, 0), @CL_ID,
			@VD_ID, @IB_PRICE, @IB_SUM, @IB_COUNT, @IB_FULL_PAY,
			@HLF_ID, @PER_ID, @IB_LOCK, @IB_NOTE
			)

	SELECT @IB_ID = ID
	FROM @TBL

	EXEC Common.PROTOCOL_VALUE_GET 'INCOME_BOOK', @IB_ID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'INCOME_BOOK', '���� ������ ��', @IB_ID, @OLD, @NEW
END
GO
GRANT EXECUTE ON [Income].[INCOME_BOOK_INSERT] TO rl_income_book_i;
GO
