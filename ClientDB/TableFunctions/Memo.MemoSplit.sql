USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Memo].[MemoSplit]
(
	@LIST		NVARCHAR(MAX),
	@MONTH		UNIQUEIDENTIFIER,
	@MON_CNT	INT,
	@TOTAL_NDS	MONEY
)
RETURNS @TBL TABLE
(
	/* ��� ����������� ������� ��� ���������� "�����������" ������ � "�������"*/
	TP			TINYINT,
	SystemID	INT,
	DistrTypeID	INT,
	CNT			INT,
	PRICE		MONEY,
	TAX_PRICE	MONEY,
	TOTAL_PRICE	MONEY
)
AS
BEGIN
	DECLARE @DATE SMALLDATETIME

	SELECT @DATE = START
	FROM Common.Period
	WHERE ID = @MONTH

	IF @DATE >= '20181001'
		SET @DATE = '20190101'

	DECLARE @DefaultTaxRate DECIMAL(8, 4)

	SELECT @DefaultTaxRate = TOTAL_RATE
	FROM Common.TaxDefaultSelect(@DATE)

	IF (@MON_CNT = 1) OR (ROUND((@TOTAL_NDS / @MON_CNT / @DefaultTaxRate), 2) * @DefaultTaxRate * @MON_CNT = @TOTAL_NDS)
	BEGIN
		/* ��� ������, ����� ��������*/
		DECLARE @MON_PRICE_NDS	MONEY

		SET @MON_PRICE_NDS = ROUND((@TOTAL_NDS / @MON_CNT), 2)

		INSERT INTO @TBL(TP, SystemID, DistrTypeID, CNT, PRICE, TAX_PRICE, TOTAL_PRICE)
			SELECT 1, SystemID, DistrTypeID, CNT, PRICE, TAX_PRICE, TOTAL_PRICE
			FROM Memo.MemoPriceSplit(@LIST, @MONTH, @MON_PRICE_NDS)
	END
	ELSE
	BEGIN
		/* ��� ����� ����� �� ��������*/
		DECLARE @MON_PRICE_1_NDS	MONEY
		DECLARE @MON_PRICE_2_NDS	MONEY

		SET @MON_PRICE_1_NDS = FLOOR(@TOTAL_NDS / @MON_CNT / @DefaultTaxRate) * @DefaultTaxRate
		SET @MON_PRICE_2_NDS = @TOTAL_NDS - @MON_PRICE_1_NDS * (@MON_CNT - 1)

		INSERT INTO @TBL(TP, SystemID, DistrTypeID, CNT, PRICE, TAX_PRICE, TOTAL_PRICE)
			SELECT 1, SystemID, DistrTypeID, CNT, PRICE, TAX_PRICE, TOTAL_PRICE
			FROM Memo.MemoPriceSplit(@LIST, @MONTH, @MON_PRICE_1_NDS)

		INSERT INTO @TBL(TP, SystemID, DistrTypeID, CNT, PRICE, TAX_PRICE, TOTAL_PRICE)
			SELECT 2, SystemID, DistrTypeID, CNT, PRICE, TAX_PRICE, TOTAL_PRICE
			FROM Memo.MemoPriceSplit(@LIST, @MONTH, @MON_PRICE_2_NDS)
	END

	RETURN
END
GO
