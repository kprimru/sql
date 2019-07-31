USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [USR.ProcessorFamily_LAST_UPDATE]
		ON USR.ProcessorFamily
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'ProcessorFamily' AND ReferenceSchema = 'USR'