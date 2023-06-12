USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Din].[SystemType_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Din].[SystemType_LAST_UPDATE]  ON [Din].[SystemType] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Din].[SystemType_LAST_UPDATE] ON [Din].[SystemType]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'SystemType'
		AND ReferenceSchema = 'Din';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Din', 'SystemType', GetDate();
END
GO
