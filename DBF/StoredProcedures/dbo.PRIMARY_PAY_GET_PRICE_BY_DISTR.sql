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

CREATE PROCEDURE [dbo].[PRIMARY_PAY_GET_PRICE_BY_DISTR]
	@distrid INT
AS
BEGIN
	SET NOCOUNT ON;

	-- посчитать по фин.установкам стоимость дистрибутива (если установки указаны)
	DECLARE @sncoef DECIMAL(8, 4)

	SELECT @sncoef = SN_COEF 
	FROM 		
		dbo.SystemNetTable c INNER JOIN
		dbo.SystemNetCountTable d ON d.SNC_ID_SN = c.SN_ID
	WHERE 		
		SNC_NET_COUNT = (
							SELECT RN_NET_COUNT 
							FROM 
								dbo.RegNodeTable e INNER JOIN
								dbo.DistrView f ON 
											e.RN_SYS_NAME = f.SYS_REG_NAME AND
											e.RN_DISTR_NUM = f.DIS_NUM AND
											e.RN_COMP_NUM = f.DIS_COMP_NUM	
							WHERE DIS_ID = @distrid
						)

	IF @sncoef IS NULL
		SET @sncoef = 1

	SELECT PS_PRICE * @sncoef * PP_COEF_MUL AS DIS_PRICE
	FROM 
		dbo.PriceView a INNER JOIN
		dbo.PeriodTable b ON a.PR_ID = b.PR_ID INNER JOIN
		dbo.PriceTable c ON c.PP_ID_TYPE = a.PT_ID
	WHERE SYS_ID = 
					(
						SELECT SYS_ID
						FROM dbo.DistrView
						WHERE DIS_ID = @distrid
					) AND
		GETDATE() BETWEEN b.PR_DATE AND b.PR_END_DATE AND PP_ID = 2
END