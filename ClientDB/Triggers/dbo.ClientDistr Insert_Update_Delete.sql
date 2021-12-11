USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientDistr Insert/Update/Delete]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[ClientDistr Insert/Update/Delete]  ON [dbo].[ClientDistr] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [dbo].[ClientDistr Insert/Update/Delete] ON  [dbo].[ClientDistr]
   AFTER INSERT,DELETE,UPDATE
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @IDs VarChar(Max);

    SET @IDs = REVERSE(STUFF(REVERSE(
		(
			SELECT Cast(ID_CLIENT AS VarChar(20)) + ','
			FROM
			(
				SELECT ID_CLIENT
				FROM inserted

				UNION

				SELECT ID_CLIENT
				FROM deleted
			) I
			FOR XML PATH('')
		)), 1, 1, ''));

	EXEC dbo.CLIENT_TYPE_RECALCULATE @IDs;
END
GO
