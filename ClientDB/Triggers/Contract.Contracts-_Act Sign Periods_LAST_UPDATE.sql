USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[Contracts->Act Sign Periods_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Contract].[Contracts->Act Sign Periods_LAST_UPDATE]  ON [Contract].[Contracts->Act Sign Periods] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Contract].[Contracts->Act Sign Periods_LAST_UPDATE] ON [Contract].[Contracts->Act Sign Periods]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'Contracts->Act Sign Periods'
		AND ReferenceSchema = 'Contract';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Contract', 'Contracts->Act Sign Periods', GetDate();
END
GO
