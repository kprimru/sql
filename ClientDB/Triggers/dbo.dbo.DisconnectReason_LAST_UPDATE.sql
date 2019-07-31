USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [dbo.DisconnectReason_LAST_UPDATE]
		ON dbo.DisconnectReason
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'DisconnectReason' AND ReferenceSchema = 'dbo'