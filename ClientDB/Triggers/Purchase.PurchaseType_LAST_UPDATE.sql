﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PurchaseType_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Purchase].[PurchaseType_LAST_UPDATE]  ON [Purchase].[PurchaseType] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Purchase].[PurchaseType_LAST_UPDATE] ON [Purchase].[PurchaseType]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'PurchaseType'
		AND ReferenceSchema = 'Purchase';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Purchase', 'PurchaseType', GetDate();
END
GO
