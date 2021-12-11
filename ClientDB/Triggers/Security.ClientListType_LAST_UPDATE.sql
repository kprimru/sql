USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ClientListType_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Security].[ClientListType_LAST_UPDATE]  ON [Security].[ClientListType] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Security].[ClientListType_LAST_UPDATE] ON [Security].[ClientListType]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'ClientListType'
		AND ReferenceSchema = 'Security';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Security', 'ClientListType', GetDate();
END
GO
