USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STUDY_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME, PSEDO
	FROM dbo.StudyType
	WHERE @FILTER IS NULL
		OR NAME LIKE @FILTER
		OR PSEDO LIKE @FILTER	
	ORDER BY NAME
END
