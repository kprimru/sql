USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_PRODUCT_PRICE_EDIT]
	@SPP_ID	INT,
	@PR_ID	SMALLINT,
	@SP_ID	SMALLINT,
	@PRICE	MONEY
AS
BEGIN
	SET NOCOUNT ON;

	IF @SPP_ID IS NULL
		INSERT INTO Subhost.SubhostProductPrice(SPP_ID_PERIOD, SPP_ID_PRODUCT, SPP_PRICE)
			VALUES(@PR_ID, @SP_ID, @PRICE)
	ELSE
		UPDATE Subhost.SubhostProductPrice
		SET SPP_PRICE = @PRICE
		WHERE SPP_ID = @SPP_ID
END
