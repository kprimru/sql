USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Purchase.ClaimCancelReason_LAST_UPDATE]
		ON Purchase.ClaimCancelReason
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'ClaimCancelReason' AND ReferenceSchema = 'Purchase'