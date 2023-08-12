﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[Action_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Price].[Action_LAST_UPDATE]  ON [Price].[Action] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Price].[Action_LAST_UPDATE] ON [Price].[Action]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Action'
		AND ReferenceSchema = 'Price';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Price', 'Action', GetDate();
END
GO
