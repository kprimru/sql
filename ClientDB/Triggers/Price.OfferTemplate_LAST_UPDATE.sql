USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[OfferTemplate_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Price].[OfferTemplate_LAST_UPDATE]  ON [Price].[OfferTemplate] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Price].[OfferTemplate_LAST_UPDATE] ON [Price].[OfferTemplate]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'OfferTemplate'
		AND ReferenceSchema = 'Price';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Price', 'OfferTemplate', GetDate();
END
GO
