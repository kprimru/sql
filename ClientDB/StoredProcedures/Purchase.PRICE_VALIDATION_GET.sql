USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[PRICE_VALIDATION_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PV_NAME, PV_SHORT
	FROM Purchase.PriceValidation
	WHERE PV_ID = @ID
END