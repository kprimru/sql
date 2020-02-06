USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[PRICE_DBF_IMPORT]
	@DBFMonth		UniqueIdentifier,
	@ClientMonth	UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DBFDate SmallDateTime;

	SELECT @DBFDate = DATE
	FROM Common.Month
	WHERE Id = @DBFMonth;

	DECLARE @DBFPrice Table
	(
		SYS_REG		VarChar(50)		NOT NULL,
		PRICE		Money			NOT NULL,
		PRIMARY KEY CLUSTERED(SYS_REG)
	);

	INSERT INTO @DBFPrice
	SELECT SYS_REG_NAME, PS_PRICE
	FROM dbo.DBFPriceView
	WHERE PR_DATE = @DBFDate	

	-- удялем данные за целевой месяц, мы ведь сейчас загрузим новые
	DELETE
	FROM System.Price
	WHERE ID_MONTH = @ClientMonth

	INSERT INTO System.Price(ID_SYSTEM, ID_MONTH, PRICE)
	SELECT
		[SystemId]		= S.[Id],
		[MonthId]		= @ClientMonth,
		[Price]			= D.[PRICE]
	FROM @DBFPrice D 
	INNER JOIN System.Systems S ON S.REG = D.SYS_REG;
END
