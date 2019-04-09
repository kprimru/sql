USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INNOVATION_SELECT]
	@FILTER	NVARCHAR(256) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME, NOTE, START, FINISH
	FROM dbo.Innovation
	WHERE @FILTER IS NULL
		OR NAME LIKE @FILTER
		OR NOTE LIKE @FILTER
	ORDER BY START DESC, NAME
END
