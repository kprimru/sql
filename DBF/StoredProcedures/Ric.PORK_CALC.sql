USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[PORK_CALC]
	@PR_ALG	SMALLINT,
	@PORF	DECIMAL(10, 4),
	@WEIGHT	DECIMAL(10, 4),
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

		DECLARE @PR_DATE	SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ALG

		DECLARE @RES	DECIMAL(10, 4)

		IF @PR_DATE >= '20120601'
		BEGIN
			IF @PORF < 0
				SET @RES = CASE @DEPTH WHEN 0 THEN NULL ELSE ROUND(@PORF / @DEPTH, 2) END
			ELSE
				SET @RES = ROUND(@PORF * @WEIGHT * @DEPTH, 2)
		END

		SELECT @RES AS PORK

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[PORK_CALC] TO rl_ric_kbu;
GO