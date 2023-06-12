﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Income].[INCOME_BOOK_FULL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Income].[INCOME_BOOK_FULL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Income].[INCOME_BOOK_FULL_SELECT]
	@BDATE	SMALLDATETIME		= NULL,
	@EDATE	SMALLDATETIME		= NULL,
	@CLIENT	VARCHAR(50)			= NULL,
	@HALF	UNIQUEIDENTIFIER	= NULL,
	@PER	UNIQUEIDENTIFIER	= NULL,
	@RC		INT					= NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		IB_ID, IB_DATE, IB_ID_MASTER,
		CL_ID, CL_ID_MASTER, CL_NAME,
		VD_ID, VD_ID_MASTER, VD_NAME,
		IB_NOTE,
		IB_PRICE, IB_SUM, IB_COUNT, IB_FULL_PAY,
		HLF_ID, HLF_ID_MASTER, HLF_NAME,
		PER_ID, PER_ID_MASTER, PER_NAME,
		IB_LOCK, IB_REPAY, CONVERT(BIT, IB_PAYED) AS IB_PAYED, IB_REPAYED
	FROM Income.IncomeBookFullView
	WHERE
		(IB_DATE	>=		@BDATE OR	@BDATE IS NULL) AND
		(IB_DATE	<=		@EDATE OR	@EDATE IS NULL) AND
		(CL_NAME	LIKE	@CLIENT OR	@CLIENT IS NULL) AND
		(HLF_ID_MASTER	=	@HALF	OR	@HALF	IS NULL) AND
		(PER_ID_MASTER	=	@PER	OR	@PER	IS NULL)

	SELECT @RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Income].[INCOME_BOOK_FULL_SELECT] TO rl_income_book_r;
GO
