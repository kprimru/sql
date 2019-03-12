USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[USR_FILE_KIND_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@SNAME	VARCHAR(100),
	@SHORT	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.USRFileKindTable
	SET USRFileKindName = @NAME,
		USRFileKindShortName = @SNAME,
		USRFileKindShort = @SHORT,
		USRFileKindLast = GETDATE()
	WHERE USRFileKindID = @ID
END