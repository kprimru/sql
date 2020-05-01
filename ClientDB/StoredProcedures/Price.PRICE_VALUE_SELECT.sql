USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[PRICE_VALUE_SELECT]
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

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @PRICE		MONEY
		DECLARE @OLD_PRICE	MONEY
		DECLARE	@NEW_PRICE	MONEY

		DECLARE @DT	SMALLDATETIME

		SELECT @DT = START FROM Common.Period WHERE ID = @MONTH

		IF NOT EXISTS
			(
				SELECT *
				FROM Price.SystemPrice
				WHERE ID_MONTH = @MONTH
			)
			SELECT @MONTH = ID
			FROM Common.Period
			WHERE TYPE = 2 AND START =
				(
					SELECT MAX(START)
					FROM
						Common.Period a
						INNER JOIN Price.SystemPrice b ON a.ID = b.ID_MONTH
					WHERE TYPE = 2 AND START <= @DT
				)

		DECLARE @MONTH_DATE SMALLDATETIME

		SELECT @MONTH_DATE = START
		FROM Common.Period
		WHERE ID = @MONTH

		IF @OLD_DISC IS NULL AND @NEW_DISC IS NOT NULL
			SET @OLD_DISC = @NEW_DISC

		IF @SYS IS NOT NULL
			SELECT @PRICE = PRICE
			FROM
				Price.SystemPrice
				INNER JOIN dbo.SystemTable ON SystemID = ID_SYSTEM
			WHERE ID_MONTH = @MONTH AND SystemID = @SYS
		ELSE
		BEGIN
			SELECT @OLD_PRICE = PRICE
			FROM
				Price.SystemPrice
				INNER JOIN dbo.SystemTable ON SystemID = ID_SYSTEM
			WHERE ID_MONTH = @MONTH AND SystemID = @SYS_OLD

			SELECT @NEW_PRICE = PRICE
			FROM
				Price.SystemPrice
				INNER JOIN dbo.SystemTable ON SystemID = ID_SYSTEM
			WHERE ID_MONTH = @MONTH AND SystemID = @SYS_NEW
		END

		DECLARE @COEF		DECIMAL(8, 4)
		DECLARE	@OLD_COEF	DECIMAL(8, 4)
		DECLARE	@NEW_COEF	DECIMAL(8, 4)

		DECLARE @RND		SMALLINT
		DECLARE	@OLD_RND	SMALLINT
		DECLARE	@NEW_RND	SMALLINT

		IF @NET IS NOT NULL
		BEGIN
			SET @COEF = dbo.DistrCoef(ISNULL(@SYS, @SYS_NEW), @NET, '', @MONTH_DATE)
			SET @RND = dbo.DistrCoefRound(ISNULL(@SYS, @SYS_NEW), @NET, '', @MONTH_DATE)
		END
		ELSE
		BEGIN
			SET @OLD_COEF = dbo.DistrCoef(ISNULL(@SYS, @SYS_OLD), @NET_OLD, '', @MONTH_DATE)
			SET @OLD_RND = dbo.DistrCoefRound(ISNULL(@SYS, @SYS_OLD), @NET_OLD, '', @MONTH_DATE)

			SET @NEW_COEF = dbo.DistrCoef(ISNULL(@SYS, @SYS_NEW), @NET_NEW, '', @MONTH_DATE)
			SET @NEW_RND = dbo.DistrCoefRound(ISNULL(@SYS, @SYS_NEW), @NET_NEW, '', @MONTH_DATE)
		END

		IF @PRICE IS NOT NULL
		BEGIN
			IF @COEF IS NOT NULL
			BEGIN
				IF @ACTION IS NULL
					SET @DELIVERY = ROUND(ROUND(ROUND(@PRICE * @COEF, @RND) * 3, 2) * (100 - ISNULL(@NEW_DISC, 0))/100, 2)
				ELSE
					SET @DELIVERY = ROUND(ROUND(ROUND(@PRICE * @COEF, @RND), 2) * (100 - ISNULL(@NEW_DISC, 0))/100, 2)
				SET @SUPPORT = ROUND(@PRICE * @COEF, @RND)
			END
			ELSE
			BEGIN
				SET @DELIVERY = ROUND(ROUND(@PRICE * @NEW_COEF, @NEW_RND) * (100 - ISNULL(@NEW_DISC, 0))/100, 2) - ROUND(ROUND(@PRICE * @OLD_COEF, @OLD_RND) * (100 - ISNULL(@NEW_DISC, 0))/100, 2)
				SET @SUPPORT = ROUND(@PRICE * @NEW_COEF, @NEW_RND)
			END
		END
		ELSE
		BEGIN
			IF @COEF IS NOT NULL
			BEGIN
				SET @DELIVERY = ROUND(ROUND(@NEW_PRICE * @COEF, @RND) * (100 - ISNULL(@NEW_DISC, 0))/100, 2) - ROUND(ROUND(@OLD_PRICE * @COEF, @RND) * (100 - ISNULL(@OLD_DISC, 0))/100, 2)
				SET @SUPPORT = @NEW_PRICE * @COEF
			END
			ELSE
			BEGIN
				SET @DELIVERY = ROUND(ROUND(@NEW_PRICE * @NEW_COEF, @NEW_RND) * (100 - ISNULL(@NEW_DISC, 0))/100, 2) - ROUND(ROUND(@OLD_PRICE * @OLD_COEF, @OLD_RND) * (100 - ISNULL(@OLD_DISC, 0))/100, 2)
				SET @SUPPORT = @NEW_PRICE * @NEW_COEF
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
GRANT EXECUTE ON [Price].[PRICE_VALUE_SELECT] TO rl_commercial_offer_r;
GO