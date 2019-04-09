USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[SIGN_PERIOD_SELECT]
	@FILTER VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SP_ID, SP_NAME, SP_SHORT
	FROM Purchase.SignPeriod
	WHERE @FILTER IS NULL
		OR SP_NAME LIKE @FILTER
		OR SP_SHORT LIKE @FILTER
	ORDER BY SP_SHORT
END