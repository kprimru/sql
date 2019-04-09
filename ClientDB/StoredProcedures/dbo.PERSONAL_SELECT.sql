USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PERSONAL_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PersonalID, DepartmentName, PersonalShortName, PersonalFullName
	FROM dbo.PersonalTable	
	WHERE @FILTER IS NULL
		OR DepartmentName LIKE @FILTER
		OR PersonalShortName LIKE @FILTER
		OR PersonalFullName LIKE @FILTER
	ORDER BY PersonalShortName
END