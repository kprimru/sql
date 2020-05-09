USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[REPORT_SELECT]
	@PERIOD	SMALLINT
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

		/*
		SELECT
			ID, PR_NAME, COUR_NAME, COUR_BASE, TO_ID, CL_ID, CL_PSEDO, CL_BASE, CLT_ID,
			CLT_NAME, SYS_COUNT, CL_SUM, TO_COUNT PRICE, TOTAL_PRICE, COUR_MIN, COUR_MAX,
			COUR_PERCENT, COEF, CL_PAY, CL_ACT_KGS, TOTAL, COUR_COUNT, CL_TERR
		FROM
			asdasd
		*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[REPORT_SELECT] TO rl_courier_pay;
GO