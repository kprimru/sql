USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[Files@Refresh]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[Files@Refresh]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[Files@Refresh]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Document_Id Int;

	WHILE (1 = 1) BEGIN
		SELECT TOP (1)
			@Document_Id = D.ID
		FROM dbo.ScanDocument AS D
		WHERE D.ExportDateTime IS NULL
			AND D.STATUS = 1

		IF @@RowCount = 0
			BREAK;

		EXEC [dbo].[Files@Refresh(Internal)] @Document_Id = @Document_Id;

		UPDATE dbo.ScanDocument SET [ExportDateTime] = GetDate() WHERE ID = @Document_Id;
	END;
END;
GO
