USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Purchase].[GoodRequirement_LAST_UPDATE]
		ON Purchase.GoodRequirement
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'GoodRequirement' AND ReferenceSchema = 'Purchase'