USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[PRICE_ADD] 
	@pricename VARCHAR(50),
	@pricetypeid INT, 
	@pricecoefmul NUMERIC(8, 4),
	@pricecoefadd MONEY,
	@active BIT = 1,
	@returnvalue BIT = 1  
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.PriceTable(PP_NAME, PP_ID_TYPE, PP_COEF_MUL, PP_COEF_ADD, PP_ACTIVE) 
	VALUES (@pricename, @pricetypeid, @pricecoefmul, @pricecoefadd, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END







