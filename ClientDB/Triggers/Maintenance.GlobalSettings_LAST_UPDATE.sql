USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [Maintenance].[GlobalSettings_LAST_UPDATE] ON [Maintenance].[GlobalSettings]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'GlobalSettings'
		AND ReferenceSchema = 'Maintenance';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Maintenance', 'GlobalSettings', GetDate();
END
GO
