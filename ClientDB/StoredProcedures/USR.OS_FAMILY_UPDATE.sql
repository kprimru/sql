USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[OS_FAMILY_UPDATE]
	@ID		INT,
	@NAME	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE USR.OSFamily
	SET OF_NAME = @NAME,
		OF_LAST = GETDATE()
	WHERE OF_ID = @ID
END