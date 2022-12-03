USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalPriceCoef]', 'FN') IS NULL EXEC('CREATE FUNCTION [Maintenance].[GlobalPriceCoef] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [Maintenance].[GlobalPriceCoef]
()
RETURNS Numeric(12,4)
AS
BEGIN
	DECLARE @RES Numeric(12,4)

	SELECT @RES = Cast(GS_VALUE AS Numeric(12,4))
	FROM Maintenance.GlobalSettings
	WHERE GS_NAME = 'PRICE_COEF'

	RETURN @RES
END
GO
