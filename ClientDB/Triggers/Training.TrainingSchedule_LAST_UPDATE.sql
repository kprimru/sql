USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Training].[TrainingSchedule_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Training].[TrainingSchedule_LAST_UPDATE]  ON [Training].[TrainingSchedule] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Training].[TrainingSchedule_LAST_UPDATE] ON [Training].[TrainingSchedule]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'TrainingSchedule'
		AND ReferenceSchema = 'Training';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Training', 'TrainingSchedule', GetDate();
END
GO
