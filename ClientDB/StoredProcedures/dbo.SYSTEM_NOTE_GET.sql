USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SYSTEM_NOTE_GET]
	@ID		INT	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT NOTE
	FROM dbo.SystemNote	
	WHERE ID_SYSTEM = @ID
END