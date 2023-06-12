﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ContractFoundation_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[ContractFoundation_LAST_UPDATE]  ON [dbo].[ContractFoundation] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [dbo].[ContractFoundation_LAST_UPDATE] ON [dbo].[ContractFoundation]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'ContractFoundation'
		AND ReferenceSchema = 'dbo';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'dbo', 'ContractFoundation', GetDate();
END
GO
