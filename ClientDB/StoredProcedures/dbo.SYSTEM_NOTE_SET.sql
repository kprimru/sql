USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SYSTEM_NOTE_SET]
	@ID		INT,
	@NOTE	VARBINARY(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.SystemNote
	SET NOTE = @NOTE
	WHERE ID_SYSTEM = @ID

	IF @@ROWCOUNT = 0
		INSERT INTO dbo.SystemNote(ID_SYSTEM, NOTE)
			VALUES(@ID, @NOTE)
END