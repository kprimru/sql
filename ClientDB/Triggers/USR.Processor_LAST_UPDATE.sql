USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[Processor_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [USR].[Processor_LAST_UPDATE]  ON [USR].[Processor] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [USR].[Processor_LAST_UPDATE] ON [USR].[Processor]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Processor'
		AND ReferenceSchema = 'USR';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'USR', 'Processor', GetDate();
END
GO
