USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[MoneyToString]', 'FN') IS NULL EXEC('CREATE FUNCTION [Common].[MoneyToString] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Common].[MoneyToString]
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

	RETURN Common.NumToStr(@rpart, 1) + ' рубл' +
           CASE
				WHEN @rattr = 1 THEN 'ь'
				WHEN @rattr IN (2, 3, 4) THEN 'я'
				ELSE 'ей'
			END + ' ' +
			RIGHT('0' + CAST(@cpart AS VARCHAR(2)), 2) + ' копе' +
			CASE
				WHEN @cattr = 1 THEN 'йка'
				WHEN @cattr IN (2, 3, 4) THEN 'йки'
				ELSE 'ек'
			END
END
GO
