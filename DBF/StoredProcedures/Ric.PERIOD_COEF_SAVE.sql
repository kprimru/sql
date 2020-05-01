USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[PERIOD_COEF_SAVE]
	@PR_ID	SMALLINT,
	@GS_VALUE	DECIMAL(10, 4),
	@GNA_VALUE	DECIMAL(10, 4),
	@ST_VALUE	DECIMAL(10, 4),
	@WC_VALUE	DECIMAL(10, 4)
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

		DECLARE @QR_ID	SMALLINT

		SET @QR_ID = dbo.PeriodQuarter(@PR_ID)

		UPDATE Ric.GrowStandard
		SET GS_VALUE = @GS_VALUE
		WHERE GS_ID_QUARTER = @QR_ID

		IF @@ROWCOUNT = 0
			INSERT INTO Ric.GrowStandard(GS_ID_QUARTER, GS_VALUE)
				SELECT @QR_ID, @GS_VALUE

		UPDATE Ric.GrowNetworkAvg
		SET GNA_VALUE = @GNA_VALUE
		WHERE GNA_ID_QUARTER = @QR_ID

		IF @@ROWCOUNT = 0
			INSERT INTO Ric.GrowNetworkAvg(GNA_ID_QUARTER, GNA_VALUE)
				SELECT @QR_ID, @GNA_VALUE

		UPDATE Ric.Stage
		SET ST_VALUE = @ST_VALUE
		WHERE ST_ID_QUARTER = @QR_ID

		IF @@ROWCOUNT = 0
			INSERT INTO Ric.Stage(ST_ID_QUARTER, ST_VALUE)
				SELECT @QR_ID, @ST_VALUE

		UPDATE Ric.WeightCorrection
		SET WC_VALUE = @WC_VALUE
		WHERE WC_ID_QUARTER = @QR_ID

		IF @@ROWCOUNT = 0
			INSERT INTO Ric.WeightCorrection(WC_ID_QUARTER, WC_VALUE)
				SELECT @QR_ID, @WC_VALUE
				
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Ric].[PERIOD_COEF_SAVE] TO rl_ric_kbu;
GO