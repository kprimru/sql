USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[IncomeSaldoView]
AS
	SELECT 
		ID_ID, IN_ID, IN_DATE, IN_ID_CLIENT, ID_ID_DISTR, ID_PRICE, SL_ID, SL_REST, --ID_ID_PERIOD,
		/*
			если сальдо >= 0 - то авансовая с/ф на полную стоимость
			если сальдо < 0 и сумма долга больше или равна оплате (то есть после оплаты сальдо не выйдет в плюс) - то с/ф не формируется
			если сальдо < 0 и сумма долга меньше оплаты - то с/ф на сумму разницы оплаты и долга
		*/
		CASE 
			WHEN SL_REST >= ID_PRICE THEN 0
			WHEN SL_REST < ID_PRICE AND ABS(SL_REST - ID_PRICE) >= ID_PRICE THEN NULL
			WHEN SL_REST < ID_PRICE AND ABS(SL_REST - ID_PRICE) <= ID_PRICE THEN ABS(SL_REST - ID_PRICE)
		END AS DELTA
	FROM
		(
			SELECT 
				SL_ID, ID_ID, IN_ID, IN_DATE, IN_ID_CLIENT, ID_ID_DISTR, SUM(ID_PRICE) AS ID_PRICE, ID_ID_PERIOD,
				/*ISNULL(
        				(
    						SELECT TOP 1 SL_REST
							FROM dbo.SaldoTable z
							WHERE z.SL_ID_CLIENT = IN_ID_CLIENT AND z.SL_ID_DISTR = ID_ID_DISTR
								AND z.SL_DATE <= IN_DATE
								AND z.SL_ID < c.SL_ID
							ORDER BY SL_DATE DESC, SL_ID DESC
						), 0) AS SL_REST
				*/
				SL_REST
			FROM 
				dbo.IncomeTable a
				INNER JOIN dbo.IncomeDistrTable b ON IN_ID = ID_ID_INCOME
				INNER JOIN dbo.SaldoTable c ON SL_ID_IN_DIS = ID_ID
			GROUP BY IN_ID, IN_ID_CLIENT, ID_ID_DISTR, IN_DATE, ID_ID, SL_ID, SL_REST, ID_ID_PERIOD
		) AS a
		
	