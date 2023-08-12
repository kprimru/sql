USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[PRICE_VALUE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[PRICE_VALUE_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Price].[PRICE_VALUE_SELECT]
	@MONTH		UNIQUEIDENTIFIER,
	@SYS		INT,
	@SYS_OLD	INT,
	@SYS_NEW	INT,
	@NET		INT,
	@NET_OLD	INT,
	@NET_NEW	INT,
	@DELIVERY	MONEY = NULL OUTPUT,
	@SUPPORT	MONEY = NULL OUTPUT,
	@OLD_DISC	DECIMAL(6, 2) = NULL,
	@NEW_DISC	DECIMAL(6, 2) = NULL,
	@ACTION		UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@PRICE			Money,
		@OLD_PRICE		Money,
		@NEW_PRICE		Money,
		@Date			SmallDateTime,

		@COEF			Decimal(8, 4),
		@OLD_COEF		Decimal(8, 4),
		@NEW_COEF		Decimal(8, 4),

		@RND			SmallInt,
		@OLD_RND		SmallInt,
		@NEW_RND		SmallInt;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @Date = [START]
		FROM [Common].[Period]
		WHERE [ID] = @MONTH;

		IF @OLD_DISC IS NULL AND @NEW_DISC IS NOT NULL
			SET @OLD_DISC = @NEW_DISC

		-- TODO: не проверяется SystemType в расчете цены
		IF @SYS IS NOT NULL
			SELECT @PRICE = Price
			FROM [Price].[DistrPriceWrapper](@SYS, NULL, NULL, NULL, @Date)
		ELSE
		BEGIN
			SELECT @OLD_PRICE = Price
			FROM [Price].[DistrPriceWrapper](@SYS_OLD, NULL, NULL, NULL, @Date);

			SELECT @NEW_PRICE = Price
			FROM [Price].[DistrPriceWrapper](@SYS_NEW, NULL, NULL, NULL, @Date);
		END

		IF @NET IS NOT NULL
		BEGIN
			SELECT
				@COEF = [DistrCoef],
				@RND = [DistrCoefRound]
			FROM [Price].[DistrPriceWrapper](ISNULL(@SYS, @SYS_NEW), @NET, NULL, '', @Date);
		END
		ELSE
		BEGIN
			SELECT
				@OLD_COEF = [DistrCoef],
				@OLD_RND = [DistrCoefRound]
			FROM [Price].[DistrPriceWrapper](ISNULL(@SYS, @SYS_OLD), @NET_OLD, NULL, '', @Date);

			SELECT
				@NEW_COEF = [DistrCoef],
				@NEW_RND = [DistrCoefRound]
			FROM [Price].[DistrPriceWrapper](ISNULL(@SYS, @SYS_NEW), @NET_NEW, NULL, '', @Date);
		END

		IF @PRICE IS NOT NULL
		BEGIN
			IF @COEF IS NOT NULL
			BEGIN
				IF @ACTION IS NULL
					SET @DELIVERY = ROUND(ROUND([dbo].[DistrPrice](@PRICE, @COEF, @RND) * 3, 2) * (100 - ISNULL(@NEW_DISC, 0))/100, 2)
				ELSE
					SET @DELIVERY = ROUND(ROUND([dbo].[DistrPrice](@PRICE, @COEF, @RND), 2) * (100 - ISNULL(@NEW_DISC, 0))/100, 2)
				SET @SUPPORT = [dbo].[DistrPrice](@PRICE, @COEF, @RND)
			END
			ELSE
			BEGIN
				SET @DELIVERY = ROUND([dbo].[DistrPrice](@PRICE, @NEW_COEF, @NEW_RND) * (100 - ISNULL(@NEW_DISC, 0))/100, 2) - ROUND([dbo].[DistrPrice](@PRICE, @OLD_COEF, @OLD_RND) * (100 - ISNULL(@NEW_DISC, 0))/100, 2)
				SET @SUPPORT = [dbo].[DistrPrice](@PRICE, @NEW_COEF, @NEW_RND)
			END
		END
		ELSE
		BEGIN
			IF @COEF IS NOT NULL
			BEGIN
				SET @DELIVERY = ROUND([dbo].[DistrPrice](@NEW_PRICE, @COEF, @RND) * (100 - ISNULL(@NEW_DISC, 0))/100, 2) - ROUND([dbo].[DistrPrice](@OLD_PRICE, @COEF, @RND) * (100 - ISNULL(@OLD_DISC, 0))/100, 2)
				SET @SUPPORT = [dbo].[DistrPrice](@NEW_PRICE, @COEF, @RND)
			END
			ELSE
			BEGIN
				SET @DELIVERY = ROUND([dbo].[DistrPrice](@NEW_PRICE, @NEW_COEF, @NEW_RND) * (100 - ISNULL(@NEW_DISC, 0))/100, 2) - ROUND([dbo].[DistrPrice](@OLD_PRICE, @OLD_COEF, @OLD_RND) * (100 - ISNULL(@OLD_DISC, 0))/100, 2)
				SET @SUPPORT = [dbo].[DistrPrice](@NEW_PRICE, @NEW_COEF, @NEW_RND);
			END
		END

		IF @DELIVERY < 0
			SET @DELIVERY = 0

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[PRICE_VALUE_SELECT] TO rl_commercial_offer_r;
GO
