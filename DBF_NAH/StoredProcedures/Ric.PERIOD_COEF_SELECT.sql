USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[PERIOD_COEF_SELECT]
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

		SELECT
			ISNULL(
				(
					SELECT GS_VALUE
					FROM Ric.GrowStandard
					WHERE GS_ID_QUARTER = dbo.PeriodQuarter(@PR_ID)
				),
				(
					SELECT TOP 1 GS_VALUE
					FROM
						Ric.GrowStandard
						INNER JOIN dbo.Quarter ON GS_ID_QUARTER = QR_ID
					WHERE QR_BEGIN <= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_ID)
					ORDER BY QR_BEGIN DESC
				)) AS GS_VALUE,
			ISNULL(
				(
					SELECT GNA_VALUE
					FROM Ric.GrowNetworkAvg
					WHERE GNA_ID_QUARTER = dbo.PeriodQuarter(@PR_ID)
				),
				(
					SELECT TOP 1 GNA_VALUE
					FROM
						Ric.GrowNetworkAvg
						INNER JOIN dbo.Quarter ON GNA_ID_QUARTER = QR_ID
					WHERE QR_BEGIN <= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_ID)
					ORDER BY QR_BEGIN DESC
				)) AS GNA_VALUE,
			ISNULL(
				(
					SELECT ST_VALUE
					FROM Ric.Stage
					WHERE ST_ID_QUARTER = dbo.PeriodQuarter(@PR_ID)
				),
				(
					SELECT TOP 1 ST_VALUE
					FROM
						Ric.Stage
						INNER JOIN dbo.Quarter ON ST_ID_QUARTER = QR_ID
					WHERE QR_BEGIN <= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_ID)
					ORDER BY QR_BEGIN DESC
				)) AS ST_VALUE,
			ISNULL(
				(
					SELECT WC_VALUE
					FROM Ric.WeightCorrection
					WHERE WC_ID_QUARTER = dbo.PeriodQuarter(@PR_ID)
				),
				(
					SELECT TOP 1 WC_VALUE
					FROM
						Ric.WeightCorrection
						INNER JOIN dbo.Quarter ON WC_ID_QUARTER = QR_ID
					WHERE QR_BEGIN <= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_ID)
					ORDER BY QR_BEGIN DESC
				)) AS WC_VALUE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Ric].[PERIOD_COEF_SELECT] TO rl_ric_kbu;
GO
