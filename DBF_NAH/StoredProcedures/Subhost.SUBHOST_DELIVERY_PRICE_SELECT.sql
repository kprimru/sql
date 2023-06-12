USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SUBHOST_DELIVERY_PRICE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[SUBHOST_DELIVERY_PRICE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[SUBHOST_DELIVERY_PRICE_SELECT]
	@SH_ID SMALLINT,
	@PR_ID SMALLINT
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
			PT_ID, SYS_SHORT_NAME, PTS_ID_ST, PS_PRICE
		FROM
			dbo.PriceTypeTable INNER JOIN
			dbo.PriceSystemTable ON PT_ID = PS_ID_TYPE INNER JOIN
			dbo.PriceTypeSystemTable ON PTS_ID_PT = PT_ID INNER JOIN
			dbo.SystemTable ON SYS_ID = PS_ID_SYSTEM
		WHERE PT_ID_GROUP IN (4, 6) AND PS_ID_PERIOD = @PR_ID
			AND NOT EXISTS
				(
					SELECT *
					FROM Subhost.SubhostPriceSystemTable
					WHERE SPS_ID_HOST = @SH_ID
						AND SPS_ID_PERIOD = @PR_ID
						AND SPS_ID_TYPE = PT_ID
						AND SPS_ID_SYSTEM = PS_ID_SYSTEM
				)

		UNION ALL

		SELECT
			PT_ID, SYS_SHORT_NAME, PTS_ID_ST, SPS_PRICE
		FROM
			dbo.PriceTypeTable INNER JOIN
			Subhost.SubhostPriceSystemTable ON PT_ID = SPS_ID_TYPE INNER JOIN
			dbo.PriceTypeSystemTable ON PTS_ID_PT = PT_ID INNER JOIN
			dbo.SystemTable ON SYS_ID = SPS_ID_SYSTEM
		WHERE PT_ID_GROUP IN (4, 6)
			AND SPS_ID_PERIOD = @PR_ID
			AND SPS_ID_HOST = @SH_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_DELIVERY_PRICE_SELECT] TO rl_subhost_calc;
GO
