USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRICE_COPY]
	@SOURCE	SMALLINT,
	@DEST	SMALLINT,
	@COEF	DECIMAL(8, 4),
	@REPL	BIT
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

		IF @REPL = 1
			DELETE FROM Subhost.SubhostProductPrice WHERE SPP_ID_PERIOD = @DEST

		INSERT INTO Subhost.SubhostProductPrice(SPP_ID_PERIOD, SPP_ID_PRODUCT, SPP_PRICE)
			SELECT @DEST, SPP_ID_PRODUCT, CAST(ROUND(SPP_PRICE * @COEF, 0) AS MONEY)
			FROM Subhost.SubhostProductPrice
			WHERE SPP_ID_PERIOD = @SOURCE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PRICE_COPY] TO rl_subhost_calc;
GO
