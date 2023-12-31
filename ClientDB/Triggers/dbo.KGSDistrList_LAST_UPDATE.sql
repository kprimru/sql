USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[KGSDistrList_LAST_UPDATE] ON [dbo].[KGSDistrList]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'KGSDistrList'
		AND ReferenceSchema = 'dbo';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'dbo', 'KGSDistrList', GetDate();
END
GO
