USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[OFFER_OTHER_GET]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT NOTE
	FROM Price.OfferOther
END
