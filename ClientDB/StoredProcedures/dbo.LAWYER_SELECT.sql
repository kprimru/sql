USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LAWYER_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT LW_ID, LW_SHORT, LW_FULL, LW_LOGIN
	FROM dbo.Lawyer
	WHERE @FILTER IS NULL
		OR LW_FULL LIKE @FILTER
		OR LW_SHORT LIKE @FILTER
		OR LW_LOGIN LIKE @FILTER
	ORDER BY LW_SHORT
END