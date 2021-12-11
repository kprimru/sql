USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[Status_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Contract].[Status_LAST_UPDATE]  ON [Contract].[Status] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Contract].[Status_LAST_UPDATE] ON [Contract].[Status]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Status'
		AND ReferenceSchema = 'Contract';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Contract', 'Status', GetDate();
END
GO
