USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [dbo.LessonPlaceTable_LAST_UPDATE]
		ON dbo.LessonPlaceTable
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'LessonPlaceTable' AND ReferenceSchema = 'dbo'