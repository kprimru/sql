USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Templates->Types_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Seminar].[Templates->Types_LAST_UPDATE]  ON [Seminar].[Templates->Types] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Seminar].[Templates->Types_LAST_UPDATE] ON [Seminar].[Templates->Types]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Templates->Types'
		AND ReferenceSchema = 'Seminar';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Seminar', 'Templates->Types', GetDate();
END
GO
