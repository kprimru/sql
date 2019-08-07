USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Purchase].[PartnerRequirement_LAST_UPDATE]
		ON Purchase.PartnerRequirement
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'PartnerRequirement' AND ReferenceSchema = 'Purchase'