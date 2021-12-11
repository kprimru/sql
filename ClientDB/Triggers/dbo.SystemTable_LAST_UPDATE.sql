USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SystemTable_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[SystemTable_LAST_UPDATE]  ON [dbo].[SystemTable] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [dbo].[SystemTable_LAST_UPDATE] ON [dbo].[SystemTable]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'SystemTable'
		AND ReferenceSchema = 'dbo';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'dbo', 'SystemTable', GetDate();
END
GO
