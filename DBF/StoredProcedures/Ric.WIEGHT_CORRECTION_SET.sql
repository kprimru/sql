USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Ric].[WIEGHT_CORRECTION_SET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Ric].[WIEGHT_CORRECTION_SET]  AS SELECT 1')
GO
ALTER PROCEDURE [Ric].[WIEGHT_CORRECTION_SET]
	@DATE	SMALLDATETIME,
	@VALUE	DECIMAL(8, 4)
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

		DECLARE @PERIOD SMALLINT

		SELECT @PERIOD = PR_ID
		FROM dbo.PeriodTable
		WHERE PR_DATE = @DATE

		UPDATE Ric.WeightCorrectionMonth
		SET WC_VALUE = @VALUE
		WHERE WC_ID_PERIOD = @PERIOD

		IF @@ROWCOUNT = 0
			INSERT INTO Ric.WeightCorrectionMonth(WC_ID_PERIOD, WC_VALUE)
				VALUES(@PERIOD, @VALUE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[WIEGHT_CORRECTION_SET] TO rl_ric_kbu;
GO
