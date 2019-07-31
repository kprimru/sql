USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Purchase.TradeSite_LAST_UPDATE]
		ON Purchase.TradeSite
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'TradeSite' AND ReferenceSchema = 'Purchase'