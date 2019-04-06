USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ActSaldoView]
AS
	SELECT 
		AD_ID, ACT_ID, ACT_DATE, ACT_ID_CLIENT, AD_ID_DISTR, AD_TOTAL_PRICE, SL_ID, SL_REST,
		/*
			если сальдо >= 0 - то закрыли и деньшги еще остались - аванс в чистейшем виде. На полную сумму
			если сальдо < 0 и сумма долга больше или равна оплате (то есть после оплаты сальдо не выйдет в плюс) - то с/ф не формируется
			если сальдо < 0 и сумма долга меньше оплаты - то с/ф на сумму разницы оплаты и долга
		*/
		CASE 
			WHEN SL_REST >= 0 THEN 0
			WHEN SL_REST < 0 AND ABS(SL_REST) >= AD_TOTAL_PRICE THEN NULL -- аванса не было - закрыли полностью в долг
			WHEN SL_REST < 0 AND ABS(SL_REST) <= AD_TOTAL_PRICE THEN AD_TOTAL_PRICE - ABS(SL_REST) -- был аванс на сумму AD_TOTAL_PRICE - ABS(SL_REST)
		END AS DELTA
	FROM
		(
			SELECT 
				SL_ID, AD_ID, ACT_ID, ACT_DATE, ACT_ID_CLIENT, AD_ID_DISTR, SUM(AD_TOTAL_PRICE) AS AD_TOTAL_PRICE,
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
				dbo.ActTable a
				INNER JOIN dbo.ActDistrTable b ON ACT_ID = AD_ID_ACT
				INNER JOIN dbo.SaldoTable c ON SL_ID_ACT_DIS = AD_ID
			GROUP BY ACT_ID, ACT_ID_CLIENT, AD_ID_DISTR, ACT_DATE, AD_ID, SL_ID, SL_REST
		) AS a
		
	