USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[MoneyFormat]
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

	RETURN CAST(@rpart AS VARCHAR(20)) + ',' + RIGHT('0' + CAST(@cpart AS VARCHAR(2)), 2)
END
GO
