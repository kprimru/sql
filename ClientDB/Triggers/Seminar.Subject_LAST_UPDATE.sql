﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Subject_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Seminar].[Subject_LAST_UPDATE]  ON [Seminar].[Subject] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Seminar].[Subject_LAST_UPDATE] ON [Seminar].[Subject]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Subject'
		AND ReferenceSchema = 'Seminar';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Seminar', 'Subject', GetDate();
END
GO
