USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DOCUMENT_GRANT_TYPE_INSERT]
	@NAME	VARCHAR(50),
	@DEF	BIT,
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	IF @DEF = 1
		UPDATE dbo.DocumentGrantType
		SET DEF = 0	

	INSERT INTO dbo.DocumentGrantType(NAME, DEF)
		OUTPUT INSERTED.ID INTO @TBL
		VALUES(@NAME, @DEF)	

	SELECT @ID = ID FROM @TBL
END