USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:         Денисов Алексей
Описание:      Выбрать данные о всех дистрибутивах клиента
*/

CREATE PROCEDURE [dbo].[CLIENT_DISTR_PAY_SELECT]
	@clientid INT,
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		DIS_ID, DIS_STR, DIS_PRICE, 
		CAST(ROUND(DIS_PRICE * ISNULL(TX_PERCENT / 100, 0), 2) AS MONEY) AS DIS_TAX_PRICE, 
		CAST(ROUND(DIS_PRICE * (1 + ISNULL(TX_PERCENT / 100, 0)), 2) AS MONEY) AS DIS_TOTAL_PRICE
	FROM 
		dbo.DistrPriceView a INNER JOIN
		dbo.SaleObjectTable b ON a.SYS_ID_SO = b.SO_ID INNER JOIN
		dbo.TaxTable c ON c.TX_ID = b.SO_ID_TAX
	WHERE CD_ID_CLIENT = @clientid AND PR_ID = @periodid
	ORDER BY SYS_ORDER

	SET NOCOUNT OFF
END














