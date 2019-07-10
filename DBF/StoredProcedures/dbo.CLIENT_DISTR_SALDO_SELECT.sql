USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:		
*/

CREATE PROCEDURE [dbo].[CLIENT_DISTR_SALDO_SELECT]
	-- Список параметров процедуры
	@clientid INT,
	@distrid INT	
AS
BEGIN
	-- SET NOCOUNT ON обязателен для использования в хранимых процедурах.
	-- Позволяет избежать лишней информации и сетевого траффика.

	SET NOCOUNT ON;

	-- Текст процедуры ниже
	SELECT 
		a.SL_ID, SL_TP, CL_FULL_NAME, SL_DATE, a.DIS_STR, BD_TOTAL_PRICE, a.ID_PRICE, AD_TOTAL_PRICE,
		CSD_TOTAL_PRICE, a.SL_REST, a.SL_BEZ_NDS, BPR_DATE, a.IN_DATE, IN_PAY_NUM, APR_DATE, CPR_DATE, b.DELTA AS SL_DELTA, 
		CASE TX_PERCENT
			WHEN 0 THEN 0 
			ELSE
				CAST(ROUND((a.ID_PRICE - b.DELTA) - CAST(ROUND((a.ID_PRICE - b.DELTA) /(1 + ROUND(TX_PERCENT / 100, 2)), 2) AS MONEY), 2) AS MONEY)
		END AS AVANS
		--a.ID_PRICE - b.DELTA AS AVANS
	FROM 
		dbo.SaldoDetailView a
		LEFT OUTER JOIN dbo.IncomeSaldoView b ON a.SL_ID = b.SL_ID
		LEFT OUTER JOIN dbo.DistrView z ON ID_ID_DISTR = z.DIS_ID
		LEFT OUTER JOIN dbo.SaleObjectTable ON SYS_ID_SO = SO_ID
		LEFT OUTER JOIN dbo.TaxTable ON SO_ID_TAX = TX_ID
	WHERE CL_ID = @clientid AND a.DIS_ID = @distrid
	ORDER BY SL_DATE , SL_TP , SL_ID, APR_DATE, IPR_DATE, BPR_DATE
END





