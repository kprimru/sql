USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[CALC_COEF_SAVE]
	@PR_ID			SMALLINT,
	@PRICE			DECIMAL(10, 4),
	@INC_DISC		DECIMAL(10, 4),
	@PREPAY_RATE	DECIMAL(10, 4),
	@PREPAY			MONEY,
	@PREPAY_DISC	DECIMAL(10, 4)
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

		UPDATE Ric.CalcCoef
		SET CC_PRICE			= @PRICE,
			CC_INCREASE_DISC	= @INC_DISC,
			CC_PREPAY_RATE		=	@PREPAY_RATE,
			CC_PREPAY			=	@PREPAY,
			CC_PREPAY_DISC		=	@PREPAY_DISC
		WHERE CC_ID_PERIOD = @PR_ID

		IF @@ROWCOUNT = 0
			INSERT INTO Ric.CalcCoef(CC_ID_PERIOD, CC_PRICE, CC_INCREASE_DISC, CC_PREPAY_RATE, CC_PREPAY, CC_PREPAY_DISC)
				VALUES(@PR_ID, @PRICE, @INC_DISC, @PREPAY_RATE, @PREPAY, @PREPAY_DISC)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Ric].[CALC_COEF_SAVE] TO rl_ric_kbu;
GO
