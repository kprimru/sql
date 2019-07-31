USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [dbo.CallDirection_LAST_UPDATE]
		ON dbo.CallDirection
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'CallDirection' AND ReferenceSchema = 'dbo'