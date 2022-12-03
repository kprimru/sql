USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[DefaultDeliveryPriceGet]()
RETURNS MONEY
AS
BEGIN
	RETURN Round(60 * [dbo].[PriceCoef@Get](), 2);
END
GO
GRANT EXECUTE ON [dbo].[DefaultDeliveryPriceGet] TO public;
GO
