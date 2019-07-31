USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Maintenance.GlobalSettings_LAST_UPDATE]
		ON Maintenance.GlobalSettings
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'GlobalSettings' AND ReferenceSchema = 'Maintenance'