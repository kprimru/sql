USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_CALC_PRODUCT_STUDY_GET]
	@PR_ID	SMALLINT,
	@SH_ID	SMALLINT,
	@HIDE	BIT = 0
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
			SPG_ID, ROW_NUMBER() OVER (ORDER BY SP_NAME) AS SP_ORDER, SP_NAME, 
			ISNULL(SPC_COUNT, 0) AS SPC_COUNT, 
			ISNULL(CONVERT(MONEY, ROUND(SPP_PRICE * (100 + ISNULL(SP_COEF, 0))/100, 2)), 0) AS SPP_PRICE, 
			ISNULL(SPC_COUNT, 0) * ISNULL(CONVERT(MONEY, ROUND(SPP_PRICE * (100 + ISNULL(SP_COEF, 0))/100, 2)), 0) AS SPP_TOTAL
		FROM
			Subhost.SubhostProduct INNER JOIN
			Subhost.SubhostProductGroup ON SPG_ID = SP_ID_GROUP LEFT OUTER JOIN
			Subhost.SubhostProductCalc ON SPC_ID_PROD = SP_ID 
									AND SPC_ID_PERIOD = @PR_ID 
									AND SPC_ID_SUBHOST = @SH_ID LEFT OUTER JOIN
			Subhost.SubhostProductPrice ON SPP_ID_PERIOD = @PR_ID 
									AND SPP_ID_PRODUCT = SP_ID
		WHERE SPG_ID = 2 AND (@HIDE = 0 OR SPC_COUNT <> 0)
		ORDER BY SPG_NAME, SP_NAME
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
