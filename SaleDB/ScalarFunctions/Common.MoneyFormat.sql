USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Common].[MoneyFormat]
(
	@VALUE MONEY
)
RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE @rpart BIGINT
	DECLARE @rattr TINYINT
	DECLARE @cpart TINYINT
	DECLARE @cattr TINYINT
	
	SET @rpart = FLOOR(@VALUE)     
	SET @rattr = @rpart % 100
	
	IF @rattr > 19 
		SET @rattr = @rattr % 10
		
	SET @cpart = (@VALUE - @rpart) * 100
	
	IF @cpart > 19 
		SET @cattr = @cpart % 10 
	ELSE 
		SET @cattr = @cpart
		
	DECLARE @RUB_STR VARCHAR(200)
	
	SET @RUB_STR = ''
	
	IF @rpart > 1000
		SET @RUB_STR = CONVERT(VARCHAR(20), ROUND(@rpart / 1000, 0)) + ' ' + 
			CASE 
				WHEN @rpart - 1000 * ROUND(@rpart / 1000, 0) > 100 THEN ''
				WHEN @rpart - 1000 * ROUND(@rpart / 1000, 0) > 10 THEN '0'
				WHEN @rpart - 1000 * ROUND(@rpart / 1000, 0) > 1 THEN '00'
				ELSE '000'
			END + CONVERT(VARCHAR(20), @rpart - 1000 * ROUND(@rpart / 1000, 0))
	ELSE
		SET @RUB_STR = CONVERT(VARCHAR(20), @rpart)	
		
	RETURN @RUB_STR + ',' + RIGHT('0' + CAST(@cpart AS VARCHAR(2)), 2)
END