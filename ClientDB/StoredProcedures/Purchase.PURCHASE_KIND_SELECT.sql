USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[PURCHASE_KIND_SELECT]
	@FILTER VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PK_ID, PK_NAME
	FROM Purchase.PurchaseKind
	WHERE @FILTER IS NULL
		OR PK_NAME LIKE @FILTER
	ORDER BY PK_NAME
END