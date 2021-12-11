USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Status_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Seminar].[Status_LAST_UPDATE]  ON [Seminar].[Status] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Seminar].[Status_LAST_UPDATE] ON [Seminar].[Status]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Status'
		AND ReferenceSchema = 'Seminar';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Seminar', 'Status', GetDate();
END
GO
