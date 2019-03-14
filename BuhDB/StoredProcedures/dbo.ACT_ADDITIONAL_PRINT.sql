USE [BuhDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[ACT_ADDITIONAL_PRINT]
	@ACT INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SystemName, SystemSet, SystemPrice, TaxPrice, SystemPrice + TaxPrice AS TotalPrice
	FROM ActSystemsTable WITH(NOLOCK) 	
	WHERE ActID = @ACT AND (SystemName LIKE '%Yubikey%' OR SystemName LIKE '%פכ‎ר%')
	ORDER BY SystemOrder
END
