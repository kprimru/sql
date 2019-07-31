USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Purchase.PlacementOrder_LAST_UPDATE]
		ON Purchase.PlacementOrder
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'PlacementOrder' AND ReferenceSchema = 'Purchase'