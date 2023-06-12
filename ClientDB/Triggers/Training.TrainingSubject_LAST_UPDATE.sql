USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Training].[TrainingSubject_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Training].[TrainingSubject_LAST_UPDATE]  ON [Training].[TrainingSubject] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Training].[TrainingSubject_LAST_UPDATE] ON [Training].[TrainingSubject]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'TrainingSubject'
		AND ReferenceSchema = 'Training';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Training', 'TrainingSubject', GetDate();
END
GO
