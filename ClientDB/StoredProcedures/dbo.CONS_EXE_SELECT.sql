USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONS_EXE_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ConsExeVersionID, ConsExeVersionName, ConsExeVersionActive, ConsExeVersionBegin, ConsExeVersionEnd
	FROM dbo.ConsExeVersionTable
	WHERE @FILTER IS NULL
		OR ConsExeVersionName LIKE @FILTER
	ORDER BY ConsExeVersionName DESC
END