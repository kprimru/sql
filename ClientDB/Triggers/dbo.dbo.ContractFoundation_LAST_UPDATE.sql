USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [dbo.ContractFoundation_LAST_UPDATE]
		ON dbo.ContractFoundation
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'ContractFoundation' AND ReferenceSchema = 'dbo'