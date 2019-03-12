USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[PERSONAL_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PersonalID, DepartmentName, PersonalShortName, PersonalFullName
	FROM dbo.PersonalTable	
	WHERE PersonalID = @ID
END