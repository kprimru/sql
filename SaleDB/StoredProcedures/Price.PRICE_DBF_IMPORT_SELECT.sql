USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[PRICE_DBF_IMPORT_SELECT]
	@DBFMonth		UniqueIdentifier,
	@ClientMonth	UniqueIdentifier,
	@OnlyDiff		Bit					= 0
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

	DECLARE @ClientPrice Table
	(
		SYS_REG		VarChar(50)		NOT NULL,
		PRICE		Money			NOT NULL,
		PRIMARY KEY CLUSTERED(SYS_REG)
	);

	INSERT INTO @DBFPrice
	SELECT SYS_REG_NAME, PS_PRICE
	FROM dbo.DBFPriceView
	WHERE PR_DATE = @DBFDate

	INSERT INTO @ClientPrice
	SELECT REG, PRICE
	FROM System.Price P
	INNER JOIN System.Systems S ON P.ID_SYSTEM = S.ID
	WHERE ID_MONTH = @ClientMonth

	SELECT
		[SystemShortName]	= S.[SHORT],
		[ClientPrice]		= P.[ClientPrice],
		[DBFPrice]			= P.[DBFPrice],
		[PriceDelta]		= IsNull([DBFPrice], 0) - IsNull([ClientPrice], 0)
	FROM
	(
		SELECT
			[SYS_REG_NAME]	= IsNull(C.[SYS_REG], D.[SYS_REG]),
			[ClientPrice]	= C.[PRICE],
			[DBFPrice]		= D.[PRICE]
		FROM @ClientPrice C
		FULL JOIN @DBFPrice D ON C.SYS_REG = D.SYS_REG
	) AS P
	INNER JOIN System.Systems S ON S.REG = P.SYS_REG_NAME
	WHERE @OnlyDiff = 0
		OR IsNull([DBFPrice], 0) - IsNull([ClientPrice], 0) != 0 
	ORDER BY S.[ORD]
END
