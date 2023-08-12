USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[ContractExecutionProvision_LAST_UPDATE]', 'TR') IS NULL EXEC('CREATE TRIGGER [Purchase].[ContractExecutionProvision_LAST_UPDATE]  ON [Purchase].[ContractExecutionProvision] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
CREATE OR ALTER TRIGGER [Purchase].[ContractExecutionProvision_LAST_UPDATE] ON [Purchase].[ContractExecutionProvision]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Common.Reference
	SET ReferenceLast = GETDATE()
	WHERE ReferenceName = 'ContractExecutionProvision'
		AND ReferenceSchema = 'Purchase';

	IF @@RowCount = 0
		INSERT INTO Common.Reference(ReferenceSchema, ReferenceName, ReferenceLast)
		SELECT 'Purchase', 'ContractExecutionProvision', GetDate();
END
GO
