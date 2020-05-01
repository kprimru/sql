USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[CALC_COEF_SELECT]
	@PR_ID	SMALLINT
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

		IF EXISTS
			(
				SELECT *
				FROM Ric.CalcCoef
				WHERE CC_ID_PERIOD = @PR_ID
			)
			SELECT CC_PRICE, CC_INCREASE_DISC, CC_PREPAY_RATE, CC_PREPAY, CC_PREPAY_DISC
			FROM Ric.CalcCoef
			WHERE CC_ID_PERIOD = @PR_ID
		ELSE
			SELECT TOP 1 CC_PRICE, CC_INCREASE_DISC, CC_PREPAY_RATE, CC_PREPAY, CC_PREPAY_DISC
			FROM Ric.CalcCoef
			WHERE CC_ID_PERIOD = dbo.PeriodDelta(@PR_ID, -1)
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Ric].[CALC_COEF_SELECT] TO rl_ric_kbu;
GO