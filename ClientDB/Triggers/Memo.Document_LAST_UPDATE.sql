﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[Document_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Memo].[Document_LAST_UPDATE]  ON [Memo].[Document] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Memo].[Document_LAST_UPDATE] ON [Memo].[Document]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Document'
		AND ReferenceSchema = 'Memo';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Memo', 'Document', GetDate();
END
GO
