USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[DEPTH_COEF_SELECT]
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

		DECLARE @QR_ID	SMALLINT

		SELECT @QR_ID = dbo.PeriodQuarter(@PR_ID)

		SELECT QR_ID, QR_NAME, DC_VALUE, DC_VALUE AS DC_ORIGIN, DC_VALUE AS DC_COEF
		FROM
			(
				SELECT dbo.QuarterDelta(@QR_ID, 0) AS QR
				UNION ALL
				SELECT dbo.QuarterDelta(@QR_ID, -1) AS QR
				UNION ALL
				SELECT dbo.QuarterDelta(@QR_ID, -2) AS QR
				UNION ALL
				SELECT dbo.QuarterDelta(@QR_ID, -3) AS QR
			) AS o_O
			INNER JOIN dbo.Quarter ON QR_ID = QR
			LEFT OUTER JOIN Ric.DepthCoef ON DC_ID_QUARTER = QR_ID
		ORDER BY QR_BEGIN DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Ric].[DEPTH_COEF_SELECT] TO rl_ric_kbu;
GO