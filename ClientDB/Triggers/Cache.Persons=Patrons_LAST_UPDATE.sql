USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Cache].[Persons=Patrons_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Cache].[Persons=Patrons_LAST_UPDATE]  ON [Cache].[Persons=Patrons] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Cache].[Persons=Patrons_LAST_UPDATE] ON [Cache].[Persons=Patrons]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Persons=Patrons'
		AND ReferenceSchema = 'Cache';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Cache', 'Persons=Patrons', GetDate();
END
GO
