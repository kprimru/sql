USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SUBHOST_PRODUCT_GROUP_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[SUBHOST_PRODUCT_GROUP_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRODUCT_GROUP_SELECT]
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

		SELECT SPG_ID, SPG_NAME, SPG_ACTIVE
		FROM Subhost.SubhostProductGroup
		WHERE SPG_ACTIVE = ISNULL(@ACTIVE, SPG_ACTIVE)
		ORDER BY SPG_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PRODUCT_GROUP_SELECT] TO rl_subhost_product_group_r;
GO
