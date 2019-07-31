USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [dbo.ClientTypeTable_LAST_UPDATE]
		ON dbo.ClientTypeTable
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'ClientTypeTable' AND ReferenceSchema = 'dbo'