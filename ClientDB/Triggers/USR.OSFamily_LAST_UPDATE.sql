﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[OSFamily_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [USR].[OSFamily_LAST_UPDATE]  ON [USR].[OSFamily] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [USR].[OSFamily_LAST_UPDATE] ON [USR].[OSFamily]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'OSFamily'
		AND ReferenceSchema = 'USR';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'USR', 'OSFamily', GetDate();
END
GO
