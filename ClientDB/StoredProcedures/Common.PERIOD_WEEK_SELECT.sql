USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Common].[PERIOD_WEEK_SELECT]
	@FILTER	NVARCHAR(200) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME, START, FINISH
	FROM Common.Period
	WHERE TYPE = 1
		AND ACTIVE = 1
		AND (NAME LIKE @FILTER OR @FILTER IS NULL)
	ORDER BY START 
END
