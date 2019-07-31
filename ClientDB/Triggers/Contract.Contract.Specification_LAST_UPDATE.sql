USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Contract.Specification_LAST_UPDATE]
		ON Contract.Specification
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'Specification' AND ReferenceSchema = 'Contract'