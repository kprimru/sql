USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Common].[TAX_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME, CAPTION, RATE, [DEFAULT]
	FROM Common.Tax
	WHERE @FILTER IS NULL
		OR NAME LIKE @FILTER
		OR CAPTION LIKE @FILTER
		OR CONVERT(VARCHAR(50), RATE) LIKE @FILTER
	ORDER BY RATE
END