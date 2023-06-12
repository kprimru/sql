USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[MailingType_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Common].[MailingType_LAST_UPDATE]  ON [Common].[MailingType] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Common].[MailingType_LAST_UPDATE] ON [Common].[MailingType]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'MailingType'
		AND ReferenceSchema = 'Common';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Common', 'MailingType', GetDate();
END
GO
