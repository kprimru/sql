USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRODUCT_EDIT]
	@SP_ID	INT,
	@SPG_ID	SMALLINT,
	@SP_NAME	VARCHAR(100),
	@UN_ID	INT,
	@COEF	DECIMAL(8, 4),
	@ACTIVE	BIT
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

		UPDATE Subhost.SubhostProduct
		SET SP_ID_GROUP = @SPG_ID,
			SP_NAME = @SP_NAME,
			SP_ID_UNIT = @UN_ID,
			SP_COEF	= @COEF,
			SP_ACTIVE = @ACTIVE
		WHERE SP_ID = @SP_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_PRODUCT_EDIT] TO rl_subhost_product_w;
GO