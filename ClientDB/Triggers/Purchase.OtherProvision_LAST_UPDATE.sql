USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[OtherProvision_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Purchase].[OtherProvision_LAST_UPDATE]  ON [Purchase].[OtherProvision] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Purchase].[OtherProvision_LAST_UPDATE] ON [Purchase].[OtherProvision]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'OtherProvision'
		AND ReferenceSchema = 'Purchase';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Purchase', 'OtherProvision', GetDate();
END
GO
