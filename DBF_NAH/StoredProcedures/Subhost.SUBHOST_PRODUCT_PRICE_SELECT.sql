USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRODUCT_PRICE_SELECT]
	@PR_ID	SMALLINT,
	@SPG_ID	SMALLINT,
	@NAME	VARCHAR(100)
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
			(
				SELECT SPP_ID
				FROM Subhost.SubhostProductPrice
				WHERE SPP_ID_PRODUCT = SP_ID
					AND SPP_ID_PERIOD = @PR_ID
			) AS SPP_ID,
			SP_ID, SP_NAME, SPG_NAME,
			(
				SELECT SPP_PRICE
				FROM Subhost.SubhostProductPrice
				WHERE SPP_ID_PRODUCT = SP_ID
					AND SPP_ID_PERIOD = @PR_ID
			) AS SPP_PRICE
		FROM
			Subhost.SubhostProduct INNER JOIN
			Subhost.SubhostProductGroup ON SPG_ID = SP_ID_GROUP
		WHERE (SPG_ID = @SPG_ID OR @SPG_ID IS NULL)
			AND SP_NAME LIKE @NAME
		ORDER BY SPG_NAME, SP_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PRODUCT_PRICE_SELECT] TO rl_subhost_calc;
GO
