USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Control].[ControlGroup_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Control].[ControlGroup_LAST_UPDATE]  ON [Control].[ControlGroup] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Control].[ControlGroup_LAST_UPDATE] ON [Control].[ControlGroup]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'ControlGroup'
		AND ReferenceSchema = 'Control';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Control', 'ControlGroup', GetDate();
END
GO
