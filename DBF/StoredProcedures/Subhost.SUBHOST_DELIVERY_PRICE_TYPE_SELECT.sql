USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_DELIVERY_PRICE_TYPE_SELECT]
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
			PT_ID, PT_NAME, PT_COEF, PTS_ID_ST
		FROM
			dbo.PriceGroupTable INNER JOIN
			dbo.PriceTypeTable ON PT_ID_GROUP = PG_ID INNER JOIN
			dbo.PriceTypeSystemTable ON PTS_ID_PT = PT_ID
		WHERE PG_ID IN (4, 6)
		ORDER BY PT_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_DELIVERY_PRICE_TYPE_SELECT] TO rl_subhost_calc;
GO
