USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SUBHOST_PRODUCT_GROUP_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[SUBHOST_PRODUCT_GROUP_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRODUCT_GROUP_GET]
	@SPG_ID	INT
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

		SELECT SPG_ID, SPG_NAME, SPG_ORDER, SPG_ACTIVE
		FROM Subhost.SubhostProductGroup
		WHERE SPG_ID = @SPG_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PRODUCT_GROUP_GET] TO rl_subhost_product_group_r;
GO
