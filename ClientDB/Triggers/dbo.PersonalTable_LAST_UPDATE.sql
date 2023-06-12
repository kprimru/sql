﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PersonalTable_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[PersonalTable_LAST_UPDATE]  ON [dbo].[PersonalTable] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [dbo].[PersonalTable_LAST_UPDATE] ON [dbo].[PersonalTable]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'PersonalTable'
		AND ReferenceSchema = 'dbo';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'dbo', 'PersonalTable', GetDate();
END
GO
