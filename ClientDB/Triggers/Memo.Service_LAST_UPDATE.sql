USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[Service_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Memo].[Service_LAST_UPDATE]  ON [Memo].[Service] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Memo].[Service_LAST_UPDATE] ON [Memo].[Service]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Service'
		AND ReferenceSchema = 'Memo';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Memo', 'Service', GetDate();
END
GO
