USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Tender].[OFFER_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM Tender.OfferDetail
	WHERE ID_OFFER = @ID

	DELETE
	FROM Tender.Offer
	WHERE ID = @ID
END
