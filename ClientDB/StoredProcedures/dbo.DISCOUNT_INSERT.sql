USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISCOUNT_INSERT]
	@VALUE	VARCHAR(100),
	@ORDER	INT,
	@ID	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.DiscountTable(DiscountValue, DiscountOrder)
		VALUES(@VALUE, @ORDER)
		
	SELECT @ID = SCOPE_IDENTITY()
END