USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Purchase].[PurchaseKind_LAST_UPDATE] ON [Purchase].[PurchaseKind]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'PurchaseKind'
		AND ReferenceSchema = 'Purchase';
	
	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Purchase', 'PurchaseKind', GetDate();
END
