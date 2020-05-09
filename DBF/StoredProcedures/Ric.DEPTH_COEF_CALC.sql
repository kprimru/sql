USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[DEPTH_COEF_CALC]
	@PR_ALG	SMALLINT,
	@DEPTH	DECIMAL(10, 4)
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

		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ALG

		DECLARE @RES	DECIMAL(10, 4)

		IF @PR_DATE >= '20120601'
		BEGIN
			IF @DEPTH <= 1
				SET @RES = 1
			ELSE IF (@DEPTH > 1) AND (@DEPTH <= 1.4)
				SET @RES = 1 + 0.5 * (@DEPTH - 1)
			ELSE IF (@DEPTH > 1.4) AND (@DEPTH <= 1.7)
				SET @RES = 1.2 + 1.5 * (@DEPTH - 1.4)
			ELSE IF @DEPTH > 1.7
				SET @RES = 1.65 + 3 * (@DEPTH - 1.7)
			ELSE
				SET @RES = NULL

			SET @RES = ROUND(@RES, 2)
		END

		SELECT @RES AS DEPTH_COEF

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[DEPTH_COEF_CALC] TO rl_ric_kbu;
GO