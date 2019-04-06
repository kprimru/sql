USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[OFFER_SELECT]
	@TENDER	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ID, a.DATE, b.SHORT, c.NAME AS TX_NAME,
		(
			SELECT COUNT(DISTINCT CLIENT)
			FROM Tender.OfferDetail z
			WHERE z.ID_OFFER = a.ID
		) AS CL_COUNT,
		(
			SELECT COUNT(*)
			FROM Tender.OfferDetail z
			WHERE z.ID_OFFER = a.ID
		) AS DIS_COUNT
	FROM 
		Tender.Offer a
		INNER JOIN dbo.Vendor b ON a.ID_VENDOR = b.ID
		INNER JOIN Common.Tax c ON a.ID_TAX = c.ID
	WHERE a.STATUS = 1
		AND a.ID_TENDER = @TENDER
	ORDER BY DATE DESC
END
