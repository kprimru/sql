USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Price].[OfferTemplate_LAST_UPDATE]
		ON Price.OfferTemplate
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'OfferTemplate' AND ReferenceSchema = 'Price'