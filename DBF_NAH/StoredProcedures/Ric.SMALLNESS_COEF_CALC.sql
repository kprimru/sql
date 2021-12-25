USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[SMALLNESS_COEF_CALC]
	@PR_ALG	SMALLINT,
	@WS		DECIMAL(10, 4),
	@QR_ID	SMALLINT,
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

		DECLARE @PR_DATE	SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ALG

		DECLARE @RES	DECIMAL(10, 4)

		DECLARE @VKSP	DECIMAL(10, 4)

		IF @PR_DATE >= '20120601'
		BEGIN
			SELECT @VKSP = Ric.VKSPGet(@PR_ALG, dbo.QuarterPeriod(dbo.QuarterDelta(@QR_ID, -2), 3), @PR_ID, @PR_ID)

			IF @VKSP / @WS <= 0.5
				SET @RES = 0.5
			ELSE IF ((@VKSP / @WS) < 1) AND ((@VKSP / @WS) > 0.5)
				SET @RES = @VKSP / @WS
			ELSE IF @VKSP / @WS >= 1
				SET @RES = 1
			ELSE
				SET @RES = NULL
		END

		SELECT @RES AS COEF

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Ric].[SMALLNESS_COEF_CALC] TO rl_ric_kbu;
GO
