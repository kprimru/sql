USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRODUCT_SELECT]
	@ACTIVE BIT = NULL
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

		SELECT SP_ID, SPG_NAME, SP_NAME, UN_NAME, SP_COEF, SP_ACTIVE
		FROM
			Subhost.SubhostProduct INNER JOIN
			Subhost.SubhostProductGroup ON SP_ID_GROUP = SPG_ID INNER JOIN
			dbo.UnitTable ON UN_ID = SP_ID_UNIT
		WHERE SP_ACTIVE = ISNULL(@ACTIVE, SP_ACTIVE)
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
GRANT EXECUTE ON [Subhost].[SUBHOST_PRODUCT_SELECT] TO rl_subhost_product_r;
GO
