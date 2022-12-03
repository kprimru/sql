USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[PriceCoef@Get]()
RETURNS Numeric(12, 4)
AS
BEGIN
	RETURN
		(
			SELECT Cast([Value] AS Numeric(12, 4))
			FROM [dbo].[Settings]
			WHERE [Name] = 'PRICE-COEF'
		)
END
GO
