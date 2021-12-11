USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[ApplyReason_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Purchase].[ApplyReason_LAST_UPDATE]  ON [Purchase].[ApplyReason] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Purchase].[ApplyReason_LAST_UPDATE] ON [Purchase].[ApplyReason]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'ApplyReason'
		AND ReferenceSchema = 'Purchase';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Purchase', 'ApplyReason', GetDate();
END
GO
