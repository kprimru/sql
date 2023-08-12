﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[Specification_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Contract].[Specification_LAST_UPDATE]  ON [Contract].[Specification] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Contract].[Specification_LAST_UPDATE] ON [Contract].[Specification]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Specification'
		AND ReferenceSchema = 'Contract';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Contract', 'Specification', GetDate();
END
GO
