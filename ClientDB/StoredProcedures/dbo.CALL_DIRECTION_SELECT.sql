USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CALL_DIRECTION_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME, DEF
	FROM dbo.CallDirection
	WHERE @FILTER IS NULL
		OR NAME LIKE @FILTER		
	ORDER BY NAME
END
