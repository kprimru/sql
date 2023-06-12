﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[MoneyFormatForEIS]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[MoneyFormatForEIS] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[MoneyFormatForEIS]
(
    @Value      Money,
    @TaxPercent Decimal(8,4),
	@Truncate	Int
)
RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE
		@Result VarChar(255);

	SET @Result = [Common].[Trim#Right](Convert(VarChar(100), Round(Cast(@Value AS Decimal(20, 12)) / (1 + @TaxPercent/100), 11, @Truncate)), '0')

    RETURN CASE WHEN @Result LIKE '%.' THEN @Result + '00' ELSE @Result END
END
GO
