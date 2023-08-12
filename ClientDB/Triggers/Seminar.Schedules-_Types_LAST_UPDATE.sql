USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Schedules->Types_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Seminar].[Schedules->Types_LAST_UPDATE]  ON [Seminar].[Schedules->Types] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Seminar].[Schedules->Types_LAST_UPDATE] ON [Seminar].[Schedules->Types]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Schedules->Types'
		AND ReferenceSchema = 'Seminar';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Seminar', 'Schedules->Types', GetDate();
END
GO
