USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[COMMERCIAL_OFFER_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ID, FULL_NAME, ADDRESS, DIRECTOR, PER_SURNAME, PER_NAME, PER_PATRON, DIRECTOR_POS, 
		DATE, NUM, NOTE, 
		DISCOUNT, INFLATION, ID_TEMPLATE
	FROM Price.CommercialOffer
	WHERE ID = @ID
END