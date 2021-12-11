USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[SystemType_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Tender].[SystemType_LAST_UPDATE]  ON [Tender].[SystemType] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Tender].[SystemType_LAST_UPDATE] ON [Tender].[SystemType]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'SystemType'
		AND ReferenceSchema = 'Tender';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Tender', 'SystemType', GetDate();
END
GO
