USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[DISCOUNT_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DiscountValue, DiscountOrder
	FROM dbo.DiscountTable
	WHERE DiscountID = @ID
END