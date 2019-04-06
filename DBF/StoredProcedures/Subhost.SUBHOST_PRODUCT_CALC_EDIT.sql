USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_PRODUCT_CALC_EDIT]
	@PR_ID	SMALLINT,
	@SH_ID	SMALLINT,
	@SP_ID	INT,
	@COUNT	INT,
	@PRICE	MONEY
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Subhost.SubhostProductCalc
	SET SPC_COUNT = @COUNT
	WHERE SPC_ID_PERIOD = @PR_ID
		AND SPC_ID_SUBHOST = @SH_ID
		AND SPC_ID_PROD = @SP_ID

	IF @@ROWCOUNT = 0
		INSERT INTO Subhost.SubhostProductCalc
					(
						SPC_ID_PERIOD, SPC_ID_SUBHOST, SPC_ID_PROD, SPC_COUNT
					)
			VALUES(@PR_ID, @SH_ID, @SP_ID, @COUNT)

	IF @PRICE IS NOT NULL
	BEGIN
		UPDATE Subhost.SubhostProductPrice
		SET SPP_PRICE = @PRICE
		WHERE SPP_ID_PERIOD = @PR_ID AND SPP_ID_PRODUCT = @SP_ID
	
		IF @@ROWCOUNT = 0
			INSERT INTO Subhost.SubhostProductPrice(SPP_ID_PERIOD, SPP_ID_PRODUCT, SPP_PRICE)
				VALUES(@PR_ID, @SP_ID, @PRICE)
	END
END
