USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [dbo.ConsExeVersionTable_LAST_UPDATE]
		ON dbo.ConsExeVersionTable
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'ConsExeVersionTable' AND ReferenceSchema = 'dbo'