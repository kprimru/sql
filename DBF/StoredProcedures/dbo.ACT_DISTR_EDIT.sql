USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[ACT_DISTR_EDIT]
	-- Список параметров процедуры
	@adid INT,
	@price MONEY,
	@taxprice MONEY,
	@totalprice MONEY
AS
BEGIN
	-- SET NOCOUNT ON обязателен для использования в хранимых процедурах.
	-- Позволяет избежать лишней информации и сетевого траффика.

	SET NOCOUNT ON;

	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT ACT_ID_CLIENT, ACT_ID, 'ACT', 'Изменение суммы', CONVERT(VARCHAR(20), PR_DATE, 104) + ' ' + DIS_STR + ' - с ' + dbo.MoneyFormat(AD_TOTAL_PRICE) + ' на ' + dbo.MoneyFormat(@totalprice)
		FROM 
			dbo.ActTable a
			INNER JOIN dbo.ActDistrTable b ON a.ACT_ID = b.AD_ID_ACT
			INNER JOIN dbo.DistrView ON DIS_ID = AD_ID_DISTR
			INNER JOIN dbo.PeriodTable ON PR_ID = AD_ID_PERIOD
		WHERE AD_ID = @adid

	-- Текст процедуры ниже
	UPDATE dbo.ActDistrTable
	SET AD_PRICE = @price,
		AD_TAX_PRICE = @taxprice,
		AD_TOTAL_PRICE = @totalprice
	WHERE AD_ID = @adid
END





