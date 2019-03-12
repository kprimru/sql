USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Common].[PERIOD_SELECT]
	@TYPE	TINYINT,
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL,
	@FILTER	VARCHAR(100) = NULL,
	@ACTIVE BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME, START, FINISH, ACTIVE
	FROM Common.Period
	WHERE (ACTIVE = 1 AND @ACTIVE IS NULL OR @ACTIVE = 1 OR @ACTIVE = 0 AND ACTIVE = 1)
		AND TYPE = @TYPE
		AND (START >= @BEGIN OR @BEGIN IS NULL)
		AND (FINISH <= @END OR @END IS NULL)
		AND (NAME LIKE @FILTER OR @FILTER IS NULL)
	ORDER BY START DESC
END