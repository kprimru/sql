USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRODUCT_PRICE_EDIT]
	@SPP_ID	INT,
	@PR_ID	SMALLINT,
	@SP_ID	SMALLINT,
	@PRICE	MONEY
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

		IF @SPP_ID IS NULL
			INSERT INTO Subhost.SubhostProductPrice(SPP_ID_PERIOD, SPP_ID_PRODUCT, SPP_PRICE)
				VALUES(@PR_ID, @SP_ID, @PRICE)
		ELSE
			UPDATE Subhost.SubhostProductPrice
			SET SPP_PRICE = @PRICE
			WHERE SPP_ID = @SPP_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PRODUCT_PRICE_EDIT] TO rl_subhost_calc;
GO
