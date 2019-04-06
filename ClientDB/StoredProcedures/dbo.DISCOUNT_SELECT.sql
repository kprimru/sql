USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISCOUNT_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DiscountID, DiscountValue
	FROM dbo.DiscountTable
	WHERE @FILTER IS NULL
		OR DiscountValue LIKE @FILTER
	ORDER BY DiscountOrder
END