USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_PRODUCT_SELECT]
	@PR_ID	SMALLINT,
	@SH_ID	SMALLINT
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

		SELECT
			SPC_ID, SP_ID, SP_NAME,
			ISNULL(SPC_COUNT, 0) AS SPC_COUNT,
			ISNULL(SPP_PRICE, 0) AS SPP_PRICE,
			SP_COEF,
			ISNULL(SPP_PRICE, 0) AS SPP_ET_PRICE
		FROM
			Subhost.SubhostProduct INNER JOIN
			Subhost.SubhostProductGroup ON SPG_ID = SP_ID_GROUP LEFT OUTER JOIN
			Subhost.SubhostProductCalc ON SPC_ID_PROD = SP_ID
									AND SPC_ID_PERIOD = @PR_ID
									AND SPC_ID_SUBHOST = @SH_ID LEFT OUTER JOIN
			Subhost.SubhostProductPrice ON SPP_ID_PERIOD = @PR_ID
									AND SPP_ID_PRODUCT = SP_ID
		WHERE SPG_ID = 3
		ORDER BY SP_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_PRODUCT_SELECT] TO rl_subhost_calc;
GO
