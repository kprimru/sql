USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[PRICE_CALC]
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

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @PRICE		MONEY
		DECLARE @PRICE_OLD	MONEY

		DECLARE @MONTH_DATE	SMALLDATETIME

		SELECT @MONTH_DATE = START
		FROM Common.Period
		WHERE ID = @MONTH

		IF @SYS_OLD IS NULL AND @NET_OLD IS NULL
			SET @PRICE_OLD = 0
		ELSE
			SELECT @PRICE_OLD = ROUND(a.PRICE * dbo.DistrCoef(ISNULL(@SYS_OLD, @SYS), ISNULL(@NET_OLD, @NET), '', @MONTH_DATE), dbo.DistrCoefRound(ISNULL(@SYS_OLD, @SYS), ISNULL(@NET_OLD, @NET), '', @MONTH_DATE))
			FROM Price.SystemPrice a
			WHERE a.ID_MONTH = @MONTH AND ID_SYSTEM = ISNULL(@SYS_OLD, @SYS)

		IF @PRICE_OLD <> 0
		BEGIN
			SET @PRICE_OLD = ROUND(@PRICE_OLD * (100 - ISNULL(@DISCOUNT, 0)) / 100, 2)
			SET @PRICE_OLD = ROUND(@PRICE_OLD * 100 * (1 + ISNULL(@INFLATION, 0)) / 100, 2)
		END

		SELECT @PRICE = ROUND(a.PRICE * dbo.DistrCoef(@SYS, @NET, '', @MONTH_DATE), dbo.DistrCoefRound(@SYS, @NET, '', @MONTH_DATE))
		FROM Price.SystemPrice a
		WHERE a.ID_MONTH = @MONTH AND ID_SYSTEM = @SYS

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