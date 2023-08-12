USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[PRICE_CALC]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[PRICE_CALC]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Tender].[PRICE_CALC]
	@SYS		INT,
	@SYS_OLD	INT,
	@NET		INT,
	@NET_OLD	INT,
	@MONTH		UNIQUEIDENTIFIER,
	@DISCOUNT	DECIMAL(8, 4),
	@INFLATION	DECIMAL(8, 4),
	@RND		BIT,
	@RES		MONEY	OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@PRICE			Money,
		@PRICE_OLD		Money,
		@MONTH_DATE		SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @MONTH_DATE = START
		FROM Common.Period
		WHERE ID = @MONTH

		-- TODO: не учитываяется тип системы
		IF @SYS_OLD IS NULL AND @NET_OLD IS NULL
			SET @PRICE_OLD = 0
		ELSE
			SELECT @PRICE_OLD = ROUND(PRICE * DistrCoef, DistrCoefRound)
			FROM [Price].[DistrPriceWrapper](ISNULL(@SYS_OLD, @SYS), ISNULL(@NET_OLD, @NET), NULL, '', @MONTH_DATE);

		IF @PRICE_OLD <> 0
		BEGIN
			SET @PRICE_OLD = ROUND(@PRICE_OLD * (100 - ISNULL(@DISCOUNT, 0)) / 100, 2)
			SET @PRICE_OLD = ROUND(@PRICE_OLD * 100 * (1 + ISNULL(@INFLATION, 0)) / 100, 2)
		END

		SELECT @PRICE = ROUND(PRICE * DistrCoef, DistrCoefRound)
		FROM [Price].[DistrPriceWrapper](@SYS, @NET, NULL, '', @MONTH_DATE);

		IF @PRICE <> 0
		BEGIN
			SET @PRICE = ROUND(@PRICE * (100 - ISNULL(@DISCOUNT, 0)) / 100, 2)
			SET @PRICE = ROUND(@PRICE * 100 * (1 + ISNULL(@INFLATION, 0)/100) / 100, 2)
		END

		IF @RND = 1
		BEGIN
			SET @PRICE = ROUND(@PRICE, 0)
			SET @PRICE_OLD = ROUND(@PRICE_OLD, 0)
		END


		SET @RES = ISNULL(@PRICE, 0) - ISNULL(@PRICE_OLD, 0)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[PRICE_CALC] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[PRICE_CALC] TO rl_tender_u;
GO
