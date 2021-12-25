USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[SERVICE_DETAIL_SELECT]
	@COURIER	SMALLINT,
	@PERIOD		SMALLINT
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

		DECLARE @ID UNIQUEIDENTIFIER

		SELECT @ID = ID
		FROM Salary.Service
		WHERE ID_COURIER = @COURIER AND ID_PERIOD = @PERIOD

		SELECT
			ID, ID_CLIENT, CL_NAME, TO_ID, TO_NAME, ID_CITY, CT_NAME, ID_TYPE, CLT_NAME, KGS, ID_PERIOD, PR_DATE, CL_TERR,
			CLIENT_TOTAL_PRICE, TO_COUNT, TO_PRICE, CPS_PERCENT, TO_CALC, CPS_MIN, CPS_MAX, CPS_INET, CPS_PAY, CPS_COEF, SYS_COUNT, KOB,
			PAY, CALC, NOTE, UPDATES, ACT, INET,
			TO_RESULT, TO_HANDS, TO_PAY_RESULT, TO_PAY_HANDS, TO_RANGE, TO_SERVICE, TO_SERVICE_COEF,
			HOLD
		FROM
			Salary.ServiceDetail a
			INNER JOIN dbo.ClientTypeTable c ON c.CLT_ID = a.ID_TYPE
			INNER JOIN dbo.PeriodTable d ON d.PR_ID = a.ID_PERIOD
		WHERE ID_SALARY = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Salary].[SERVICE_DETAIL_SELECT] TO public;
GRANT EXECUTE ON [Salary].[SERVICE_DETAIL_SELECT] TO rl_courier_pay;
GO
