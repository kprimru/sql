USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[TRADE_SITE_SELECT]
	@FILTER VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TS_ID, TS_NAME, TS_URL, TS_SHORT
	FROM Purchase.TradeSite
	WHERE @FILTER IS NULL
		OR TS_NAME LIKE @FILTER
		OR TS_SHORT LIKE @FILTER
	ORDER BY TS_URL, TS_SHORT, TS_NAME
END