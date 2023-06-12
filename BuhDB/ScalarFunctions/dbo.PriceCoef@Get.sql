USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PriceCoef@Get]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[PriceCoef@Get] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[PriceCoef@Get]()
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
