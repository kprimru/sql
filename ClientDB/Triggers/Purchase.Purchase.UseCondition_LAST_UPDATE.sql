USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Purchase.UseCondition_LAST_UPDATE]
		ON Purchase.UseCondition
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'UseCondition' AND ReferenceSchema = 'Purchase'