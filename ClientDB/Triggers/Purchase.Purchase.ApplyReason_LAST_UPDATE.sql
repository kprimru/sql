USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Purchase.ApplyReason_LAST_UPDATE]
		ON Purchase.ApplyReason
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'ApplyReason' AND ReferenceSchema = 'Purchase'