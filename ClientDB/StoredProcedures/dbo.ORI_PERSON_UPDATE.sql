USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ORI_PERSON_UPDATE]
	@ID	INT,
	@CLIENT	INT,
	@NAME	VARCHAR(250),
	@PHONE	VARCHAR(250),
	@PLACE	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.OriPersonTable
	SET OriPersonName = @NAME,
		OriPersonPhone = @PHONE,
		OriPersonPlace = @PLACE
	WHERE OriPersonID = @ID	
END