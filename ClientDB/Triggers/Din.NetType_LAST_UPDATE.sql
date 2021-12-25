USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Din].[NetType_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Din].[NetType_LAST_UPDATE]  ON [Din].[NetType] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Din].[NetType_LAST_UPDATE] ON [Din].[NetType]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'NetType'
		AND ReferenceSchema = 'Din';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Din', 'NetType', GetDate();
END
GO
