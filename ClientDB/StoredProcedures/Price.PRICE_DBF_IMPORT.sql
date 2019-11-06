USE [ClientDB]
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

	SELECT @DBFDate = START
	FROM Common.Period
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
	FROM Price.SystemPrice
	WHERE ID_MONTH = @ClientMonth

	INSERT INTO Price.SystemPrice(ID_SYSTEM, ID_MONTH, PRICE)
	SELECT
		[SystemId]		= S.[SystemId],
		[MonthId]		= @ClientMonth,
		[Price]			= D.[PRICE]
	FROM @DBFPrice D 
	INNER JOIN dbo.SystemTable S ON S.SystemBaseName = D.SYS_REG;
END
