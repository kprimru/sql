USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SubhostEmail_Type_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[SubhostEmail_Type_LAST_UPDATE]  ON [dbo].[SubhostEmail_Type] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [dbo].[SubhostEmail_Type_LAST_UPDATE] ON [SubhostEmail_Type]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE [Common].[Reference]
	SET [ReferenceLast] = GetDate()
	WHERE [ReferenceName] = 'SubhostEmail_Type'
		AND [ReferenceSchema] = 'dbo';

	IF @@RowCount = 0
		INSERT INTO [Common].[Reference]([ReferenceSchema], [ReferenceName], [ReferenceLast])
		SELECT 'dbo', 'SubhostEmail_Type', GetDate();
END
GO
