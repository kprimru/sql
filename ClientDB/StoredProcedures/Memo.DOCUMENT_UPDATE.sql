USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Memo].[DOCUMENT_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(512)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Memo.Document
	SET NAME = @NAME,
		LAST = GETDATE()
	WHERE ID = @ID
END
