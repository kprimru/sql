USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[CalcDirection_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Tender].[CalcDirection_LAST_UPDATE]  ON [Tender].[CalcDirection] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [Tender].[CalcDirection_LAST_UPDATE] ON [Tender].[CalcDirection]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'CalcDirection'
		AND ReferenceSchema = 'Tender';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Tender', 'CalcDirection', GetDate();
END
GO
