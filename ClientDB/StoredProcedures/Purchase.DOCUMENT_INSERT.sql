USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[DOCUMENT_INSERT]
	@NAME	VARCHAR(4000),
	@SHORT	VARCHAR(200),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO Purchase.Document(DC_NAME, DC_SHORT)
		OUTPUT inserted.DC_ID INTO @TBL
		VALUES(@NAME, @SHORT)
		
	SELECT @ID = ID
	FROM @TBL
END