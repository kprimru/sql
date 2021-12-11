USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[GoodRequirement_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Purchase].[GoodRequirement_LAST_UPDATE]  ON [Purchase].[GoodRequirement] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Purchase].[GoodRequirement_LAST_UPDATE] ON [Purchase].[GoodRequirement]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'GoodRequirement'
		AND ReferenceSchema = 'Purchase';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Purchase', 'GoodRequirement', GetDate();
END
GO
