USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Purchase.ContractExecutionProvision_LAST_UPDATE]
		ON Purchase.ContractExecutionProvision
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'ContractExecutionProvision' AND ReferenceSchema = 'Purchase'