USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:			������� �������/������ ��������
��������:		
*/

CREATE PROCEDURE [dbo].[DISTR_PRICE_GET]
	@distrid INT,
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 1 DIS_PRICE, CAST(ROUND(DIS_PRICE * (TX_PERCENT/100 + 1), 2) AS MONEY) AS DIS_TAX_PRICE
	FROM 
		dbo.DistrPriceView INNER JOIN
		dbo.SaleObjectTable ON SO_ID = SYS_ID_SO INNER JOIN
		dbo.TaxTable ON TX_ID = SO_ID_TAX
	WHERE DIS_ID = @distrid 
		AND PR_DATE < 
				(
					SELECT PR_DATE 
					FROM dbo.PeriodTable 
					WHERE PR_ID = @periodid
				)
	ORDER BY PR_DATE DESC
END

