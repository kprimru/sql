USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Cache].[Persons=Positions_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Cache].[Persons=Positions_LAST_UPDATE]  ON [Cache].[Persons=Positions] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Cache].[Persons=Positions_LAST_UPDATE] ON [Cache].[Persons=Positions]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Persons=Positions'
		AND ReferenceSchema = 'Cache';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Cache', 'Persons=Positions', GetDate();
END
GO
