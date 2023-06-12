USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Poll].[Blank_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Poll].[Blank_LAST_UPDATE]  ON [Poll].[Blank] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Poll].[Blank_LAST_UPDATE] ON [Poll].[Blank]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Blank'
		AND ReferenceSchema = 'Poll';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Poll', 'Blank', GetDate();
END
GO
