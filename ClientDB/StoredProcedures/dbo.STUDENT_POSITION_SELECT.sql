USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[STUDENT_POSITION_SELECT]
	@FILTER	VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT StudentPositionID, StudentPositionName
	FROM dbo.StudentPositionTable
	WHERE @FILTER IS NULL
		OR StudentPositionName LIKE @FILTER
	ORDER BY StudentPositionName
END