USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[DISCOUNT_UPDATE]
	@ID	INT,
	@VALUE	VARCHAR(100),
	@ORDER	INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.DiscountTable
	SET DiscountValue = @VALUE,
		DiscountOrder = @ORDER,
		DiscountLast = GETDATE()
	WHERE DiscountID = @ID
END