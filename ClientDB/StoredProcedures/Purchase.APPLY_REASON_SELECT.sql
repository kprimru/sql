USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[APPLY_REASON_SELECT]
	@FILTER VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT AR_ID, AR_NAME, AR_SHORT
	FROM Purchase.ApplyReason
	WHERE @FILTER IS NULL
		OR AR_NAME LIKE @FILTER
		OR AR_SHORT LIKE @FILTER
	ORDER BY AR_SHORT
END