USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRODUCT_CALC_LAST]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@GR_ID	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PRODUCT_CALC_LAST] TO rl_subhost_calc;
GO
