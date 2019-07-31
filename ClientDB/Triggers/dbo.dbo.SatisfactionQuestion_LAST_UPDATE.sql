USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [dbo.SatisfactionQuestion_LAST_UPDATE]
		ON dbo.SatisfactionQuestion
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'SatisfactionQuestion' AND ReferenceSchema = 'dbo'