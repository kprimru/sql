USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[MoneyFormatCustom]
(
    @Value      Money,
    @Delimiter  Char(1) = ','
)
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE
        @rpart         BigInt,
        @rattr         TinyInt,
        @cpart         TinyInt,
        @cattr         TinyInt;

    SET @rpart = Floor(@Value);
    SET @rattr = @rpart % 100;

    IF @rattr > 19
        SET @rattr = @rattr % 10;

    SET @cpart = (@Value - @rpart) * 100;

    IF @cpart > 19
        SET @cattr = @cpart % 10;
    ELSE
        SET @cattr = @cpart;

    RETURN CAST(@rpart AS VARCHAR(20)) + @Delimiter + RIGHT('0' + CAST(@cpart AS VARCHAR(2)), 2);
END
GO
