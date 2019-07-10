USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_PRODUCT_CALC_LAST]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@GR_ID	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM Subhost.SubhostProductCalc
	WHERE SPC_ID_SUBHOST = @SH_ID
		AND SPC_ID_PERIOD = @PR_ID

	INSERT INTO Subhost.SubhostProductPrice(SPP_ID_PERIOD, SPP_ID_PRODUCT, SPP_PRICE)
		SELECT @PR_ID, SP_ID, SPP_PRICE
		FROM 
			Subhost.SubhostProduct a
			INNER JOIN Subhost.SubhostProductPrice b ON a.SP_ID = b.SPP_ID_PRODUCT
		WHERE SP_ID_GROUP = @GR_ID 
			AND SPP_ID_PERIOD = dbo.PERIOD_PREV(@PR_ID) 
			AND NOT EXISTS
				(
					SELECT *
					FROM Subhost.SubhostProductPrice c
					WHERE c.SPP_ID_PERIOD = @PR_ID
						AND c.SPP_ID_PRODUCT = SP_ID
				)

	INSERT INTO Subhost.SubhostProductCalc(SPC_ID_SUBHOST, SPC_ID_PERIOD, SPC_ID_PROD, SPC_COUNT)
		SELECT @SH_ID, @PR_ID, SPC_ID_PROD, SPC_COUNT
		FROM 
			Subhost.SubhostProductCalc
			INNER JOIN Subhost.SubhostProduct ON SP_ID = SPC_ID_PROD
		WHERE SPC_ID_SUBHOST = @SH_ID AND SPC_ID_PERIOD = dbo.PERIOD_PREV(@PR_ID) 
			AND SP_ID_GROUP = @GR_ID
END
