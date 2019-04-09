USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PERSONAL_UPDATE]
	@ID		INT,
	@DEP	VARCHAR(50),
	@SHORT	VARCHAR(50),
	@FULL	VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.PersonalTable	
	SET DepartmentName = @DEP,
		PersonalShortName = @SHORT,
		PersonalFullName = @FULL,
		PersonalLast = GETDATE()
	WHERE PersonalID = @ID
END