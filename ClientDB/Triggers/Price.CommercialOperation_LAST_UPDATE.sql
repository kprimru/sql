USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[CommercialOperation_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Price].[CommercialOperation_LAST_UPDATE]  ON [Price].[CommercialOperation] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Price].[CommercialOperation_LAST_UPDATE] ON [Price].[CommercialOperation]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'CommercialOperation'
		AND ReferenceSchema = 'Price';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Price', 'CommercialOperation', GetDate();
END
GO
