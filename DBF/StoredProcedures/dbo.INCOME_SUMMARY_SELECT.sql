USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[INCOME_SUMMARY_SELECT]
	@date SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, SL_DATE, PR_DATE, ID_PRICE, SL_REST
		FROM dbo.SaldoIncomeSummaryView
		WHERE SL_DATE = @date
		ORDER BY CL_PSEDO, CL_ID, DIS_STR, PR_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[INCOME_SUMMARY_SELECT] TO rl_income_r;
GO