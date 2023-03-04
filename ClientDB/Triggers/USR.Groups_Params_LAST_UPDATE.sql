﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[Groups_Params_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [USR].[Groups_Params_LAST_UPDATE]  ON [USR].[Groups_Params] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO

ALTER TRIGGER [USR].[Groups_Params_LAST_UPDATE] ON [USR].[Groups_Params]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'GroupParams'
		AND ReferenceSchema = 'USR';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'USR', 'GroupParams', GetDate();
END
GO