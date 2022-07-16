USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[MoneyFormatForEIS]
(
    @Value      Money,
    @TaxPercent Decimal(8,4)
)
RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE
		@Result VarChar(255);

	--SET @Result = [Common].[Trim#Right](Convert(VarChar(100), Cast(Cast(@Value AS Decimal(20, 12)) / (1 + @TaxPercent/100) AS Decimal(20, 11))), '0')
	SET @Result = [Common].[Trim#Right](Convert(VarChar(100), Round(Cast(@Value AS Decimal(20, 12)) / (1 + @TaxPercent/100), 11, 1)), '0')

    RETURN CASE WHEN @Result LIKE '%.' THEN @Result + '00' ELSE @Result END
END
GO
