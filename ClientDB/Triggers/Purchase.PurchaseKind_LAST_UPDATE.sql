USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Purchase].[PurchaseKind_LAST_UPDATE]
		ON Purchase.PurchaseKind
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'PurchaseKind' AND ReferenceSchema = 'Purchase'