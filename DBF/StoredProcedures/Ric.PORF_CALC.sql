USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Ric].[PORF_CALC]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Ric].[PORF_CALC]  AS SELECT 1')
GO
ALTER PROCEDURE [Ric].[PORF_CALC]
	@PR_ALG	SMALLINT,
	@START	DECIMAL(10, 4),
	@END	DECIMAL(10, 4),
	@WEIGHT	DECIMAL(10, 4)
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
			SET @RES = ROUND(100 * (@END - @START + @WEIGHT) / @START, 2)
		END

		SELECT @RES AS PORF

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[PORF_CALC] TO rl_ric_kbu;
GO
