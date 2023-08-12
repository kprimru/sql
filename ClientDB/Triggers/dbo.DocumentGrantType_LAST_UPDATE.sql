﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DocumentGrantType_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[DocumentGrantType_LAST_UPDATE]  ON [dbo].[DocumentGrantType] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [dbo].[DocumentGrantType_LAST_UPDATE] ON [dbo].[DocumentGrantType]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'DocumentGrantType'
		AND ReferenceSchema = 'dbo';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'dbo', 'DocumentGrantType', GetDate();
END
GO
