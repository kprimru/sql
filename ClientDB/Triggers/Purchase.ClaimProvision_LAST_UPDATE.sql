USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[ClaimProvision_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Purchase].[ClaimProvision_LAST_UPDATE]  ON [Purchase].[ClaimProvision] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Purchase].[ClaimProvision_LAST_UPDATE] ON [Purchase].[ClaimProvision]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'ClaimProvision'
		AND ReferenceSchema = 'Purchase';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Purchase', 'ClaimProvision', GetDate();
END
GO
